#!/usr/bin/env python3
"""
Test mosquito classification fix
"""
import requests
import json

ML_SERVICE_URL = "http://localhost:8000"

def test_mosquito_classification():
    """Test that mosquito issues are classified as Sanitation"""
    print("Testing Mosquito Classification Fix...\n")
    
    test_cases = [
        {
            "text": "mosquito problem in the area",
            "expected_dept": "Sanitation",
            "expected_title": "Mosquito Problem"
        },
        {
            "text": "lots of mosquitoes near garbage dump",
            "expected_dept": "Sanitation", 
            "expected_title": "Mosquito Problem"
        },
        {
            "text": "pest control needed for insects",
            "expected_dept": "Sanitation",
            "expected_title": "Pest Issue"
        },
        {
            "text": "flies everywhere due to waste",
            "expected_dept": "Sanitation",
            "expected_title": "Fly Problem"
        }
    ]
    
    for i, test_case in enumerate(test_cases, 1):
        print(f"Test {i}: '{test_case['text']}'")
        
        try:
            payload = {"text": test_case["text"]}
            response = requests.post(f"{ML_SERVICE_URL}/classify", json=payload, timeout=10)
            
            if response.status_code == 200:
                result = response.json()
                title = result.get('title', 'No title')
                department = result.get('department', 'No department')
                severity = result.get('severity', 'No severity')
                
                print(f"  Title: '{title}'")
                print(f"  Department: {department}")
                print(f"  Severity: {severity}")
                
                # Check department
                if department == test_case['expected_dept']:
                    print(f"  ✅ Department: CORRECT")
                else:
                    print(f"  ❌ Department: WRONG (expected {test_case['expected_dept']})")
                
                # Check title
                if test_case['expected_title'].lower() in title.lower():
                    print(f"  ✅ Title: GOOD")
                else:
                    print(f"  ⚠️ Title: Different than expected")
                    
            else:
                print(f"  ❌ API Error: {response.status_code}")
                
        except Exception as e:
            print(f"  ❌ Exception: {e}")
        
        print("-" * 50)

if __name__ == "__main__":
    try:
        response = requests.get(f"{ML_SERVICE_URL}/health", timeout=5)
        if response.status_code == 200:
            print("✅ ML Service is running\n")
            test_mosquito_classification()
        else:
            print("❌ ML Service not responding")
    except Exception as e:
        print(f"❌ ML Service not running: {e}")
        print("Start with: cd ml-service && python app.py")
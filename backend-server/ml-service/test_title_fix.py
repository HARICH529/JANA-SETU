#!/usr/bin/env python3
"""
Test the title generation fix
"""
import requests
import json

ML_SERVICE_URL = "http://localhost:8000"

def test_title_fix():
    """Test that titles are generated correctly without 'Processing...' prefix"""
    print("Testing Title Generation Fix...\n")
    
    test_cases = [
        {
            "text": "Processing... dust is everywhere on the roads",
            "expected": "should not contain 'Processing...'"
        },
        {
            "text": "dust is everywhere on the roads", 
            "expected": "should generate 'Dust Problem' or similar short title"
        },
        {
            "text": "Processing... pothole causing traffic jam",
            "expected": "should not contain 'Processing...'"
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
                
                print(f"  Generated title: '{title}'")
                
                if 'Processing...' in title:
                    print(f"  ❌ FAIL: Title still contains 'Processing...'")
                elif len(title.split()) > 6:
                    print(f"  ⚠️ WARN: Title too long ({len(title.split())} words)")
                elif title.lower() == test_case['text'].lower():
                    print(f"  ❌ FAIL: Title is same as description")
                else:
                    print(f"  ✅ PASS: Title is clean and short")
                    
                print(f"  Department: {result.get('department')}")
                print(f"  Severity: {result.get('severity')}")
                
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
            test_title_fix()
        else:
            print("❌ ML Service not responding")
    except Exception as e:
        print(f"❌ ML Service not running: {e}")
        print("Start with: cd ml-service && python app.py")
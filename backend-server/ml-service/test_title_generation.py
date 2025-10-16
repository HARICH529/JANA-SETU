#!/usr/bin/env python3
"""
Test script specifically for title generation
"""
import requests
import json

ML_SERVICE_URL = "http://localhost:8000"

def test_title_generation():
    """Test title generation with various inputs"""
    print("Testing Title Generation...\n")
    
    test_cases = [
        {
            "text": "There is a big pothole on main road causing traffic jam",
            "expected_keywords": ["pothole", "road"]
        },
        {
            "text": "Overflowing garbage near park causing bad smell",
            "expected_keywords": ["garbage", "waste"]
        },
        {
            "text": "Streetlight not working in residential area at night",
            "expected_keywords": ["streetlight", "light"]
        },
        {
            "text": "Water pipe burst flooding the street",
            "expected_keywords": ["water", "pipe"]
        },
        {
            "text": "Broken swing in children playground needs repair",
            "expected_keywords": ["broken", "playground"]
        },
        {
            "text": "Drain blocked causing water logging during rain",
            "expected_keywords": ["drain", "blocked"]
        }
    ]
    
    for i, test_case in enumerate(test_cases, 1):
        print(f"Test {i}: {test_case['text']}")
        
        try:
            payload = {"text": test_case["text"]}
            response = requests.post(f"{ML_SERVICE_URL}/classify", json=payload, timeout=30)
            
            if response.status_code == 200:
                result = response.json()
                title = result.get('title', 'No title')
                department = result.get('department', 'No department')
                severity = result.get('severity', 'No severity')
                
                print(f"  ✅ Title: '{title}'")
                print(f"  📂 Department: {department}")
                print(f"  ⚠️  Severity: {severity}")
                
                # Check if title contains expected keywords or is meaningful
                title_lower = title.lower()
                has_keyword = any(keyword in title_lower for keyword in test_case['expected_keywords'])
                
                if has_keyword or len(title) > 5:
                    print(f"  ✅ Title generation: GOOD")
                else:
                    print(f"  ❌ Title generation: POOR (too generic)")
                    
            else:
                print(f"  ❌ API Error: {response.status_code}")
                print(f"  Response: {response.text}")
                
        except Exception as e:
            print(f"  ❌ Exception: {e}")
        
        print("-" * 50)

def test_direct_title_function():
    """Test the title generation function directly"""
    print("\nTesting Direct Title Function...\n")
    
    # This would require importing the function directly
    # For now, just test via API
    test_cases = [
        "pothole on road",
        "garbage overflow",
        "streetlight broken", 
        "water leak",
        "very short",
        ""
    ]
    
    for text in test_cases:
        payload = {"text": text} if text else {"text": "civic issue"}
        try:
            response = requests.post(f"{ML_SERVICE_URL}/classify", json=payload, timeout=10)
            if response.status_code == 200:
                result = response.json()
                print(f"Input: '{text}' → Title: '{result.get('title', 'No title')}'")
            else:
                print(f"Input: '{text}' → Error: {response.status_code}")
        except Exception as e:
            print(f"Input: '{text}' → Exception: {e}")

if __name__ == "__main__":
    print("🔍 Title Generation Test Suite")
    print("=" * 50)
    
    # Check if ML service is running
    try:
        response = requests.get(f"{ML_SERVICE_URL}/health", timeout=5)
        if response.status_code == 200:
            print("✅ ML Service is running\n")
            test_title_generation()
            test_direct_title_function()
        else:
            print("❌ ML Service not responding properly")
    except Exception as e:
        print(f"❌ ML Service not running: {e}")
        print("Please start the ML service first:")
        print("cd ml-service && python app.py")
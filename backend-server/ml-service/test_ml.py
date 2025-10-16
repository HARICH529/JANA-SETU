#!/usr/bin/env python3
"""
Test script for the updated ML classification service
"""
import requests
import json

ML_SERVICE_URL = "http://localhost:8000"

def test_health():
    """Test if ML service is running"""
    try:
        response = requests.get(f"{ML_SERVICE_URL}/health")
        print(f"Health check: {response.status_code}")
        print(f"Response: {response.json()}")
        return response.status_code == 200
    except Exception as e:
        print(f"Health check failed: {e}")
        return False

def test_text_classification():
    """Test text-only classification"""
    print("\n=== Testing Text Classification ===")
    
    test_cases = [
        "Overflowing garbage near park causing bad smell",
        "Big pothole on main road causing traffic jam", 
        "Streetlight not working in residential area",
        "Water pipe burst flooding the street",
        "Broken swing in children's playground"
    ]
    
    for text in test_cases:
        try:
            payload = {"text": text}
            response = requests.post(f"{ML_SERVICE_URL}/classify", json=payload)
            
            if response.status_code == 200:
                result = response.json()
                print(f"\nText: {text}")
                print(f"Result: {json.dumps(result, indent=2)}")
            else:
                print(f"Error for '{text}': {response.status_code} - {response.text}")
                
        except Exception as e:
            print(f"Exception for '{text}': {e}")

def test_image_classification():
    """Test image classification with sample URLs"""
    print("\n=== Testing Image Classification ===")
    
    # Sample image URLs (you can replace with actual images)
    test_images = [
        "https://example.com/pothole.jpg",
        "https://example.com/garbage.jpg"
    ]
    
    for image_url in test_images:
        try:
            payload = {"image_url": image_url}
            response = requests.post(f"{ML_SERVICE_URL}/classify", json=payload)
            
            print(f"\nImage: {image_url}")
            print(f"Status: {response.status_code}")
            if response.status_code != 200:
                print(f"Response: {response.text}")
                
        except Exception as e:
            print(f"Exception for '{image_url}': {e}")

def test_combined_classification():
    """Test combined text + image classification"""
    print("\n=== Testing Combined Classification ===")
    
    payload = {
        "text": "Broken streetlight causing safety issues",
        "image_url": "https://example.com/streetlight.jpg"
    }
    
    try:
        response = requests.post(f"{ML_SERVICE_URL}/classify", json=payload)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"Combined result: {json.dumps(result, indent=2)}")
        else:
            print(f"Error: {response.text}")
            
    except Exception as e:
        print(f"Exception: {e}")

def main():
    print("Testing ML Classification Service")
    print("=" * 50)
    
    # Test if service is running
    if not test_health():
        print("ML service is not running. Please start it first with:")
        print("cd ml-service && python app.py")
        return
    
    # Run tests
    test_text_classification()
    test_image_classification()
    test_combined_classification()
    
    print("\n" + "=" * 50)
    print("Testing completed!")

if __name__ == "__main__":
    main()
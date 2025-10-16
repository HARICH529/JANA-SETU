import os
import tempfile
# Set cache directories to temp folder for fresh downloads
temp_cache = os.path.join(tempfile.gettempdir(), 'ml_cache_light')
os.makedirs(temp_cache, exist_ok=True)
os.environ['HF_HOME'] = os.path.join(temp_cache, 'huggingface')
os.environ['HUGGINGFACE_HUB_CACHE'] = os.path.join(temp_cache, 'huggingface')
os.environ['TORCH_HOME'] = os.path.join(temp_cache, 'torch')
os.environ['TRANSFORMERS_CACHE'] = os.path.join(temp_cache, 'transformers')
print(f"Using lightweight cache directory: {temp_cache}")

from fastapi import FastAPI, HTTPException, UploadFile, File
from pydantic import BaseModel
import requests
from typing import Optional
import uvicorn

app = FastAPI(title="Civic Issue ML Classifier (Lightweight)", version="2.0.0")

# Lightweight classification without heavy models
print("Starting lightweight ML service...")

# Updated Labels
severity_labels = ["Minor issue", "Moderate issue", "Severe issue"]
department_labels = [
    "Sanitation and Waste Management",
    "Roads and Transport", 
    "Electricity and Streetlights",
    "Water Supply and Drainage",
    "Public Health",
    "Environment",
    "Public Safety"
]

# Mapping for output
severity_mapping = {
    "Minor issue": "LOW",
    "Moderate issue": "MEDIUM", 
    "Severe issue": "HIGH"
}

department_mapping = {
    "Sanitation and Waste Management": "Sanitation",
    "Roads and Transport": "Roads",
    "Electricity and Streetlights": "Electricity", 
    "Water Supply and Drainage": "Water",
    "Public Health": "Health",
    "Environment": "Environment",
    "Public Safety": "Safety"
}

class ClassificationRequest(BaseModel):
    text: Optional[str] = None
    image_url: Optional[str] = None
    audio_url: Optional[str] = None

class ClassificationResponse(BaseModel):
    severity: str
    department: str
    title: str
    confidence: dict
    conflicts: Optional[str] = None

def generate_keyword_title(text, department=None, max_words=4):
    """Generate title using keyword extraction"""
    try:
        text_lower = text.lower()
        
        # Enhanced issue keywords
        issue_keywords = {
            'pothole': 'Pothole Issue',
            'garbage': 'Garbage Problem', 
            'trash': 'Waste Issue',
            'waste': 'Waste Problem',
            'streetlight': 'Streetlight Issue',
            'street light': 'Streetlight Issue',
            'light': 'Lighting Issue',
            'water': 'Water Issue',
            'leak': 'Water Leak',
            'pipe': 'Pipe Issue',
            'drain': 'Drainage Issue',
            'road': 'Road Problem',
            'broken': 'Broken Item',
            'damaged': 'Damage Report',
            'not working': 'Malfunction',
            'overflow': 'Overflow Issue',
            'blocked': 'Blockage Issue',
            'dust': 'Dust Problem',
            'dirty': 'Cleanliness Issue',
            'noise': 'Noise Problem',
            'smell': 'Odor Issue',
            'crack': 'Crack Issue',
            'hole': 'Hole Problem',
            'mosquito': 'Mosquito Problem',
            'mosquitoes': 'Mosquito Problem',
            'pest': 'Pest Issue',
            'insects': 'Insect Problem',
            'flies': 'Fly Problem',
            'rats': 'Rodent Problem',
            'rodents': 'Rodent Problem',
            'toilet': 'Toilet Issue',
            'bathroom': 'Bathroom Problem',
            'sewage': 'Sewage Issue',
            'sewer': 'Sewer Problem'
        }
        
        # Find matching keywords
        sorted_keywords = sorted(issue_keywords.items(), key=lambda x: len(x[0]), reverse=True)
        for keyword, title in sorted_keywords:
            if keyword in text_lower:
                return title
        
        # Department-based fallback
        if department:
            dept_titles = {
                'Sanitation and Waste Management': 'Sanitation Issue',
                'Roads and Transport': 'Road Issue', 
                'Electricity and Streetlights': 'Electrical Issue',
                'Water Supply and Drainage': 'Water Issue',
                'Public Health': 'Health Issue',
                'Environment': 'Environmental Issue',
                'Public Safety': 'Safety Issue'
            }
            if department in dept_titles:
                return dept_titles[department]
        
        # Extract key words
        words = text.split()
        if len(words) >= 2:
            key_words = []
            for word in words[:4]:
                if len(word) > 2 and word.lower() not in ['the', 'and', 'are', 'is', 'on', 'in', 'at', 'to', 'of']:
                    key_words.append(word.title())
                if len(key_words) >= 2:
                    break
            
            if key_words:
                return ' '.join(key_words) + ' Issue'
        
        return 'Civic Issue Report'
        
    except Exception as e:
        print(f"Title generation error: {e}")
        return 'Civic Issue Report'

def classify_text_lightweight(text: str):
    """Lightweight text classification using keywords"""
    try:
        text_lower = text.lower()
        
        # Severity classification based on keywords
        high_severity_keywords = ['emergency', 'urgent', 'dangerous', 'severe', 'critical', 'major', 'serious', 'broken', 'overflow', 'blocked completely']
        low_severity_keywords = ['minor', 'small', 'little', 'slight', 'cosmetic']
        
        severity = "Moderate issue"  # default
        severity_conf = 0.6
        
        for keyword in high_severity_keywords:
            if keyword in text_lower:
                severity = "Severe issue"
                severity_conf = 0.8
                break
        
        if severity == "Moderate issue":
            for keyword in low_severity_keywords:
                if keyword in text_lower:
                    severity = "Minor issue"
                    severity_conf = 0.7
                    break
        
        # Department classification based on keywords
        department_keywords = {
            'Sanitation and Waste Management': ['garbage', 'trash', 'waste', 'dump', 'litter', 'dirty', 'smell', 'odor', 'toilet', 'bathroom', 'sewage', 'sewer', 'mosquito', 'mosquitoes', 'pest', 'insects', 'flies', 'rats', 'rodents', 'cleaning', 'hygiene'],
            'Roads and Transport': ['road', 'street', 'pothole', 'traffic', 'vehicle', 'parking', 'signal', 'zebra crossing', 'footpath', 'sidewalk', 'pavement'],
            'Electricity and Streetlights': ['electricity', 'power', 'light', 'streetlight', 'street light', 'bulb', 'wire', 'pole', 'transformer'],
            'Water Supply and Drainage': ['water', 'leak', 'pipe', 'drain', 'drainage', 'tap', 'supply', 'pressure', 'quality', 'contaminated', 'shortage'],
            'Public Health': ['health', 'medical', 'hospital', 'clinic', 'disease', 'illness', 'contamination'],
            'Environment': ['environment', 'pollution', 'air', 'noise', 'dust', 'tree', 'park', 'green'],
            'Public Safety': ['safety', 'security', 'crime', 'theft', 'violence', 'accident', 'emergency']
        }
        
        department = "Public Health"  # default
        dept_conf = 0.5
        max_matches = 0
        
        for dept, keywords in department_keywords.items():
            matches = sum(1 for keyword in keywords if keyword in text_lower)
            if matches > max_matches:
                max_matches = matches
                department = dept
                dept_conf = min(0.9, 0.5 + (matches * 0.1))
        
        title = generate_keyword_title(text, department)
        
        return severity, department, title, severity_conf, dept_conf
        
    except Exception as e:
        print(f"Lightweight classification error: {e}")
        return "Moderate issue", "Public Health", "Civic Issue", 0.5, 0.5

@app.post("/classify")
async def classify_issue(request: ClassificationRequest):
    if not request.text and not request.image_url and not request.audio_url:
        raise HTTPException(status_code=400, detail="At least one of text, image_url, or audio_url must be provided")
    
    # For lightweight version, only process text
    if request.text:
        severity, department, title, severity_conf, dept_conf = classify_text_lightweight(request.text)
    else:
        # Fallback for image/audio
        severity, department, title, severity_conf, dept_conf = "Moderate issue", "Public Health", "Issue Report", 0.5, 0.5
    
    # Map to standard format
    mapped_severity = severity_mapping.get(severity, "MEDIUM")
    mapped_department = department_mapping.get(department, "Other")
    
    response = {
        "severity": mapped_severity,
        "department": mapped_department,
        "title": title,
        "confidence": {
            "severity": round(severity_conf, 3),
            "department": round(dept_conf, 3)
        }
    }
    
    return response

@app.post("/classify-audio")
async def classify_audio_file(file: UploadFile = File(...)):
    """Lightweight audio classification - returns default values"""
    return {
        "transcribed_text": "Audio processing not available in lightweight mode",
        "severity": "MEDIUM",
        "department": "Other",
        "title": "Audio Issue Report",
        "confidence": {
            "severity": 0.5,
            "department": 0.5
        }
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy", "message": "Lightweight ML service is running", "mode": "lightweight"}

print("Lightweight ML service ready!")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
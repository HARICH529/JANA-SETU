import os
import tempfile
# Set cache directories to temp folder for fresh downloads
temp_cache = os.path.join(tempfile.gettempdir(), 'ml_cache_fresh')
os.makedirs(temp_cache, exist_ok=True)
os.environ['HF_HOME'] = os.path.join(temp_cache, 'huggingface')
os.environ['HUGGINGFACE_HUB_CACHE'] = os.path.join(temp_cache, 'huggingface')
os.environ['TORCH_HOME'] = os.path.join(temp_cache, 'torch')
os.environ['TRANSFORMERS_CACHE'] = os.path.join(temp_cache, 'transformers')
print(f"Using cache directory: {temp_cache}")
print("Models will be downloaded fresh...")

from fastapi import FastAPI, HTTPException, UploadFile, File
from pydantic import BaseModel
import torch
from PIL import Image
from transformers import (
    CLIPProcessor, CLIPModel,
    pipeline, BartTokenizer, BartForConditionalGeneration,
    WhisperProcessor, WhisperForConditionalGeneration
)
import requests
from io import BytesIO
from typing import Optional
import uvicorn
import librosa
import numpy as np

app = FastAPI(title="Civic Issue ML Classifier", version="2.0.0")

# Load models on startup with force download
print("Loading ML models with force download...")
try:
    clip_model = CLIPModel.from_pretrained("openai/clip-vit-base-patch32", force_download=True)
    clip_processor = CLIPProcessor.from_pretrained("openai/clip-vit-base-patch32", force_download=True)
    print("CLIP models loaded successfully!")
except Exception as e:
    print(f"Error loading CLIP models: {e}")
    clip_model = None
    clip_processor = None

try:
    bart_classifier = pipeline("zero-shot-classification", model="facebook/bart-large-mnli", model_kwargs={"force_download": True})
    print("BART classifier loaded successfully!")
except Exception as e:
    print(f"Error loading BART classifier: {e}")
    bart_classifier = None

try:
    bart_tokenizer = BartTokenizer.from_pretrained("facebook/bart-large-cnn", force_download=True)
    bart_summarizer = BartForConditionalGeneration.from_pretrained("facebook/bart-large-cnn", force_download=True)
    print("BART summarizer loaded successfully!")
except Exception as e:
    print(f"Error loading BART summarizer: {e}")
    bart_tokenizer = None
    bart_summarizer = None

try:
    whisper_processor = WhisperProcessor.from_pretrained("openai/whisper-base", force_download=True)
    whisper_model = WhisperForConditionalGeneration.from_pretrained("openai/whisper-base", force_download=True)
    print("Whisper models loaded successfully!")
except Exception as e:
    print(f"Error loading Whisper models: {e}")
    whisper_processor = None
    whisper_model = None

print("Model loading completed!")

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

def generate_short_title(text, department=None, max_words=4):
    """Generate short title using keyword extraction and templates"""
    # Skip BART for now as it's returning full text - go directly to keyword extraction
    return generate_keyword_title(text, department, max_words)

def generate_keyword_title(text, department=None, max_words=4):
    """Generate title using keyword extraction"""
    try:
        text_lower = text.lower()
        
        # Enhanced issue keywords with more specific matches
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
        
        # Find matching keywords (prioritize longer matches)
        sorted_keywords = sorted(issue_keywords.items(), key=lambda x: len(x[0]), reverse=True)
        for keyword, title in sorted_keywords:
            if keyword in text_lower:
                return title
        
        # Look for action words + object
        action_patterns = {
            'everywhere': 'Widespread Issue',
            'causing': 'Problem Report',
            'need': 'Repair Needed',
            'fix': 'Fix Required',
            'repair': 'Repair Needed'
        }
        
        for pattern, title in action_patterns.items():
            if pattern in text_lower:
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
        
        # Extract key nouns and create title
        words = text.split()
        if len(words) >= 2:
            # Take first 2-3 meaningful words and add "Issue"
            key_words = []
            for word in words[:4]:
                if len(word) > 2 and word.lower() not in ['the', 'and', 'are', 'is', 'on', 'in', 'at', 'to', 'of']:
                    key_words.append(word.title())
                if len(key_words) >= 2:
                    break
            
            if key_words:
                return ' '.join(key_words) + ' Issue'
        
        # Final fallback: Use first few words but limit length
        if words:
            title = ' '.join(words[:max_words]).title()
            if len(title) > 25:  # Limit title length
                title = title[:22] + '...'
            return title
        
        return 'Civic Issue Report'
        
    except Exception as e:
        print(f"Keyword title generation error: {e}")
        return 'Civic Issue Report'

def apply_department_corrections(text: str, department: str):
    """Apply post-processing rules to correct common misclassifications"""
    text_lower = text.lower()
    
    # Sanitation issues often misclassified as Environment
    sanitation_keywords = [
        'mosquito', 'mosquitoes', 'pest', 'insects', 'flies', 'rats', 'rodents',
        'garbage', 'trash', 'waste', 'dump', 'litter', 'dirty', 'smell', 'odor',
        'toilet', 'bathroom', 'sewage', 'sewer', 'cleaning', 'hygiene'
    ]
    
    # Water Supply issues
    water_keywords = [
        'water supply', 'tap water', 'drinking water', 'water shortage',
        'no water', 'water pressure', 'water quality', 'contaminated water'
    ]
    
    # Roads issues
    roads_keywords = [
        'traffic', 'vehicle', 'parking', 'signal', 'zebra crossing',
        'footpath', 'sidewalk', 'pavement'
    ]
    
    # Check for sanitation keywords
    for keyword in sanitation_keywords:
        if keyword in text_lower:
            if department in ['Environment', 'Public Health']:
                print(f"Correcting department: '{keyword}' found -> Sanitation")
                return 'Sanitation and Waste Management'
    
    # Check for water keywords
    for keyword in water_keywords:
        if keyword in text_lower:
            if department != 'Water Supply and Drainage':
                print(f"Correcting department: '{keyword}' found -> Water")
                return 'Water Supply and Drainage'
    
    # Check for roads keywords
    for keyword in roads_keywords:
        if keyword in text_lower:
            if department != 'Roads and Transport':
                print(f"Correcting department: '{keyword}' found -> Roads")
                return 'Roads and Transport'
    
    return department

def classify_text(text: str):
    """Classify text for severity and department"""
    try:
        # Clean the input text - remove temporary titles
        clean_text = text.replace('Processing...', '').strip()
        if not clean_text:
            return None, None, None, 0.0, 0.0
        
        if not bart_classifier:
            print("BART classifier not available, using fallback classification")
            # Fallback classification based on keywords
            severity = "Moderate issue"
            department = "Public Health"
            title = generate_short_title(clean_text, department)
            return severity, department, title, 0.5, 0.5
            
        severity_result = bart_classifier(clean_text, severity_labels, multi_label=False)
        department_result = bart_classifier(clean_text, department_labels, multi_label=False)
        
        severity = severity_result["labels"][0]
        department = department_result["labels"][0]
        
        # Apply post-processing corrections
        corrected_department = apply_department_corrections(clean_text, department)
        if corrected_department != department:
            department = corrected_department
        
        title = generate_short_title(clean_text, department)
        
        severity_conf = severity_result["scores"][0]
        dept_conf = department_result["scores"][0]
        
        return severity, department, title, severity_conf, dept_conf
    except Exception as e:
        print(f"Text classification error: {e}")
        return None, None, None, 0.0, 0.0

def classify_image(image_url: str):
    """Classify image for severity and department"""
    try:
        if not clip_model or not clip_processor:
            print("CLIP models not available")
            return None, None, None, 0.0, 0.0
            
        response = requests.get(image_url)
        image = Image.open(BytesIO(response.content)).convert('RGB')
        
        # Severity
        inputs = clip_processor(text=severity_labels, images=image, return_tensors="pt", padding=True)
        outputs = clip_model(**inputs)
        probs = outputs.logits_per_image.softmax(dim=1)[0]
        severity = severity_labels[torch.argmax(probs)]
        severity_conf = float(torch.max(probs))
        
        # Department
        inputs_dept = clip_processor(text=department_labels, images=image, return_tensors="pt", padding=True)
        outputs_dept = clip_model(**inputs_dept)
        probs_dept = outputs_dept.logits_per_image.softmax(dim=1)[0]
        department = department_labels[torch.argmax(probs_dept)]
        dept_conf = float(torch.max(probs_dept))
        
        # Title fallback
        title = f"Issue in {department_mapping.get(department, department)}"
        
        return severity, department, title, severity_conf, dept_conf
    except Exception as e:
        print(f"Image classification error: {e}")
        return None, None, None, 0.0, 0.0

def classify_audio(audio_url: str):
    """Classify audio by converting to text first"""
    try:
        if not whisper_processor or not whisper_model:
            print("Whisper models not available")
            return None, None, None, 0.0, 0.0
            
        # Download audio file
        response = requests.get(audio_url)
        
        # Save to temporary file
        with tempfile.NamedTemporaryFile(suffix='.wav', delete=False) as temp_file:
            temp_file.write(response.content)
            temp_path = temp_file.name
        
        # Load and process audio
        audio, sr = librosa.load(temp_path, sr=16000)
        
        # Convert to tensor
        inputs = whisper_processor(audio, return_tensors="pt", sampling_rate=16000)
        predicted_ids = whisper_model.generate(inputs["input_features"])
        text = whisper_processor.batch_decode(predicted_ids, skip_special_tokens=True)[0]
        
        # Clean up temp file
        os.unlink(temp_path)
        
        return classify_text(text)
    except Exception as e:
        print(f"Audio classification error: {e}")
        return None, None, None, 0.0, 0.0

def combine_predictions(text_pred, image_pred):
    """Combine predictions with conflict awareness"""
    if text_pred and image_pred and text_pred[0] and image_pred[0]:
        text_severity, text_department, text_title, text_sev_conf, text_dept_conf = text_pred
        img_severity, img_department, img_title, img_sev_conf, img_dept_conf = image_pred
        
        # Severity → pick the higher one
        severity_order = {"Minor issue": 0, "Moderate issue": 1, "Severe issue": 2}
        final_severity = (
            text_severity if severity_order[text_severity] >= severity_order[img_severity] else img_severity
        )
        final_sev_conf = text_sev_conf if final_severity == text_severity else img_sev_conf
        
        # Department → detect conflicts
        conflicts = None
        if text_department == img_department:
            final_department = text_department
            final_dept_conf = max(text_dept_conf, img_dept_conf)
        else:
            final_department = text_department  # Prefer text department
            final_dept_conf = text_dept_conf
            conflicts = f"Text suggests {text_department}, image suggests {img_department}"
        
        # Title → always from text
        final_title = text_title
        
        return final_severity, final_department, final_title, final_sev_conf, final_dept_conf, conflicts
    
    elif text_pred and text_pred[0]:
        return text_pred + (None,)
    elif image_pred and image_pred[0]:
        return image_pred + (None,)
    else:
        return None, None, "No title", 0.0, 0.0, None

@app.post("/classify")
async def classify_issue(request: ClassificationRequest):
    if not request.text and not request.image_url and not request.audio_url:
        raise HTTPException(status_code=400, detail="At least one of text, image_url, or audio_url must be provided")
    
    text_pred = None
    image_pred = None
    audio_pred = None
    
    # Process each input type
    if request.text:
        text_pred = classify_text(request.text)
    
    if request.image_url:
        image_pred = classify_image(request.image_url)
    
    if request.audio_url:
        audio_pred = classify_audio(request.audio_url)
    
    # Combine predictions (prioritize text, then audio, then image)
    primary_pred = text_pred or audio_pred
    result = combine_predictions(primary_pred, image_pred)
    
    if not result or not result[0]:
        raise HTTPException(status_code=500, detail="Classification failed")
    
    final_severity, final_department, final_title, severity_conf, dept_conf, conflicts = result
    
    # Map to standard format
    mapped_severity = severity_mapping.get(final_severity, "MEDIUM")
    mapped_department = department_mapping.get(final_department, "Other")
    
    response = {
        "severity": mapped_severity,
        "department": mapped_department,
        "title": final_title,
        "confidence": {
            "severity": round(severity_conf, 3),
            "department": round(dept_conf, 3)
        }
    }
    
    if conflicts:
        response["conflicts"] = conflicts
    
    return response

@app.post("/classify-audio")
async def classify_audio_file(file: UploadFile = File(...)):
    """Classify uploaded audio file"""
    try:
        # Save uploaded file temporarily
        with tempfile.NamedTemporaryFile(suffix='.wav', delete=False) as temp_file:
            content = await file.read()
            temp_file.write(content)
            temp_path = temp_file.name
        
        # Load and process audio
        audio, sr = librosa.load(temp_path, sr=16000)
        
        # Convert to tensor
        inputs = whisper_processor(audio, return_tensors="pt", sampling_rate=16000)
        predicted_ids = whisper_model.generate(inputs["input_features"])
        text = whisper_processor.batch_decode(predicted_ids, skip_special_tokens=True)[0]
        
        # Clean up temp file
        os.unlink(temp_path)
        
        # Classify the transcribed text
        result = classify_text(text)
        if not result or not result[0]:
            raise HTTPException(status_code=500, detail="Audio classification failed")
        
        severity, department, title, severity_conf, dept_conf = result
        
        return {
            "transcribed_text": text,
            "severity": severity_mapping.get(severity, "MEDIUM"),
            "department": department_mapping.get(department, "Other"),
            "title": title,
            "confidence": {
                "severity": round(severity_conf, 3),
                "department": round(dept_conf, 3)
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Audio processing failed: {str(e)}")

@app.get("/health")
async def health_check():
    return {"status": "healthy", "message": "ML service is running"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
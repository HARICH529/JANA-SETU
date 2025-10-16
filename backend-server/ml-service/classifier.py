import os
# Set cache directories to F drive before importing ML libraries
os.environ['HF_HOME'] = 'F:/ml-cache/huggingface'
os.environ['HUGGINGFACE_HUB_CACHE'] = 'F:/ml-cache/huggingface'
os.environ['TORCH_HOME'] = 'F:/ml-cache/torch'
os.environ['TRANSFORMERS_CACHE'] = 'F:/ml-cache/transformers'

import torch
from transformers import (
    CLIPProcessor, CLIPModel,
    pipeline, BartTokenizer, BartForConditionalGeneration,
    WhisperProcessor, WhisperForConditionalGeneration
)
from PIL import Image

# ------------------------------
# Load models
# ------------------------------
print("Loading models...")
clip_model = CLIPModel.from_pretrained("openai/clip-vit-base-patch32")
clip_processor = CLIPProcessor.from_pretrained("openai/clip-vit-base-patch32")

bart_classifier = pipeline("zero-shot-classification", model="facebook/bart-large-mnli")

bart_tokenizer = BartTokenizer.from_pretrained("facebook/bart-large-cnn")
bart_summarizer = BartForConditionalGeneration.from_pretrained("facebook/bart-large-cnn")

whisper_processor = WhisperProcessor.from_pretrained("openai/whisper-base")
whisper_model = WhisperForConditionalGeneration.from_pretrained("openai/whisper-base")
print("Models loaded successfully!")

# ------------------------------
# Label definitions
# ------------------------------
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

# ------------------------------
# Summarization for Short Title
# ------------------------------
def generate_short_title(text, department=None, max_words=4):
    """Generate short title using keyword extraction"""
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
        
        # Find matching keywords (prioritize longer matches)
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
        
        # Extract key words and create short title
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
        
        # Final fallback: Use first few words but limit length
        if words:
            title = ' '.join(words[:max_words]).title()
            if len(title) > 25:
                title = title[:22] + '...'
            return title
        
        return 'Civic Issue Report'
        
    except Exception as e:
        print(f"Title generation error: {e}")
        return 'Civic Issue Report'

# ------------------------------
# Classify Text
# ------------------------------
def apply_department_corrections(text: str, department: str):
    """Apply post-processing rules to correct common misclassifications"""
    text_lower = text.lower()
    
    # Sanitation issues often misclassified as Environment
    sanitation_keywords = [
        'mosquito', 'mosquitoes', 'pest', 'insects', 'flies', 'rats', 'rodents',
        'garbage', 'trash', 'waste', 'dump', 'litter', 'dirty', 'smell', 'odor',
        'toilet', 'bathroom', 'sewage', 'sewer', 'cleaning', 'hygiene'
    ]
    
    # Check for sanitation keywords
    for keyword in sanitation_keywords:
        if keyword in text_lower:
            if department in ['Environment', 'Public Health']:
                print(f"Correcting department: '{keyword}' found -> Sanitation")
                return 'Sanitation and Waste Management'
    
    return department

def classify_text(text):
    try:
        # Clean the input text - remove temporary titles
        clean_text = text.replace('Processing...', '').strip()
        if not clean_text:
            return None, None, None
            
        severity_result = bart_classifier(clean_text, severity_labels, multi_label=False)
        department_result = bart_classifier(clean_text, department_labels, multi_label=False)
        
        severity = severity_result["labels"][0]
        department = department_result["labels"][0]
        
        # Apply post-processing corrections
        corrected_department = apply_department_corrections(clean_text, department)
        if corrected_department != department:
            department = corrected_department
        
        title = generate_short_title(clean_text, department)
        
        return severity, department, title
    except Exception as e:
        print(f"Text classification error: {e}")
        return None, None, None

# ------------------------------
# Classify Image
# ------------------------------
def classify_image(image_path):
    try:
        image = Image.open(image_path).convert("RGB")

        # Severity
        inputs = clip_processor(text=severity_labels, images=image, return_tensors="pt", padding=True)
        outputs = clip_model(**inputs)
        probs = outputs.logits_per_image.softmax(dim=1)[0]
        severity = severity_labels[torch.argmax(probs)]

        # Department
        inputs_dept = clip_processor(text=department_labels, images=image, return_tensors="pt", padding=True)
        outputs_dept = clip_model(**inputs_dept)
        probs_dept = outputs_dept.logits_per_image.softmax(dim=1)[0]
        department = department_labels[torch.argmax(probs_dept)]

        # Title fallback
        title = f"Issue in {department}"

        return severity, department, title
    except Exception as e:
        print(f"Image classification error: {e}")
        return None, None, None

# ------------------------------
# Classify Audio
# ------------------------------
def classify_audio(audio_path):
    try:
        import librosa
        
        # Load audio
        audio, sr = librosa.load(audio_path, sr=16000)
        
        # Process with Whisper
        inputs = whisper_processor(audio, return_tensors="pt", sampling_rate=16000)
        predicted_ids = whisper_model.generate(inputs["input_features"])
        text = whisper_processor.batch_decode(predicted_ids, skip_special_tokens=True)[0]
        
        print(f"Transcribed text: {text}")
        return classify_text(text)
    except Exception as e:
        print(f"Audio classification error: {e}")
        return None, None, None

# ------------------------------
# Combine Predictions (conflict-aware)
# ------------------------------
def combine_predictions(text_pred, image_pred):
    if text_pred and image_pred:
        text_severity, text_department, text_title = text_pred
        img_severity, img_department, img_title = image_pred

        # Severity → pick the higher one
        severity_order = {"Minor issue": 0, "Moderate issue": 1, "Severe issue": 2}
        final_severity = (
            text_severity if severity_order[text_severity] >= severity_order[img_severity] else img_severity
        )

        # Department → detect conflicts
        if text_department == img_department:
            final_department = text_department
        else:
            final_department = f"{text_department} (conflict with image: {img_department})"

        # Title → always from text
        final_title = text_title

        return final_severity, final_department, final_title

    elif text_pred:
        return text_pred
    elif image_pred:
        return image_pred
    else:
        return "No input", "No input", "No title"

# ------------------------------
# Demo
# ------------------------------
if __name__ == "__main__":
    # Example 1: Text only
    print("=== Text Classification ===")
    text = "Overflowing garbage near park causing bad smell"
    text_pred = classify_text(text)
    print(f"Text prediction: {text_pred}")
    
    # Example 2: Text + Image combination (simulated)
    print("\n=== Combined Classification ===")
    text2 = "Big pothole near bus stand causing traffic jam"
    text_pred2 = classify_text(text2)
    
    # Simulate image prediction for streetlight issue
    simulated_image_pred = ("Minor issue", "Electricity and Streetlights", "Streetlight Issue")
    
    final = combine_predictions(text_pred2, simulated_image_pred)
    print(f"Text prediction: {text_pred2}")
    print(f"Simulated image prediction: {simulated_image_pred}")
    print(f"Combined (conflict-aware): {final}")
    
    print("\n=== Available for testing ===")
    print("- classify_text(text)")
    print("- classify_image(image_path)")
    print("- classify_audio(audio_path)")
    print("- combine_predictions(text_pred, image_pred)")
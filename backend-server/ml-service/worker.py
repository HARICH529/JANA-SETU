import os
import sys
import requests
import pymongo
from bson import ObjectId
import redis
import json
import time
from datetime import datetime

# Add parent directory to path for imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Configuration
REDIS_URL = os.getenv('REDIS_URL', 'redis://localhost:6379')
MONGO_URI = os.getenv('DB_URI', 'mongodb://localhost:27017/CivicResponses')
ML_SERVICE_URL = os.getenv('ML_SERVICE_URL', 'http://localhost:8000')

# Initialize connections
redis_client = redis.from_url(REDIS_URL)
mongo_client = pymongo.MongoClient(MONGO_URI)
db = mongo_client.get_database()

def process_classification_job(job_data):
    """Process ML classification job"""
    try:
        report_id = job_data['reportId']
        description = job_data.get('description', '')
        image_url = job_data.get('imageUrl')
        title = job_data.get('title', '')
        
        print(f"Processing classification for report {report_id}")
        
        # Prepare text for classification (only use description, ignore temporary title)
        text_input = description.strip() if description else ''
        
        # Call ML service
        payload = {}
        if text_input:
            payload['text'] = text_input
        if image_url:
            payload['image_url'] = image_url
            
        if not payload:
            print(f"No text or image for report {report_id}")
            return
            
        print(f"Sending to ML service: {payload}")
            
        response = requests.post(f"{ML_SERVICE_URL}/classify", json=payload, timeout=30)
        
        if response.status_code == 200:
            result = response.json()
            
            # Update report in database
            update_data = {
                'mlClassified': True,
                'mlSeverity': result['severity'],
                'mlDepartment': result['department'],
                'mlConfidence': result['confidence'],
                'mlTitle': result.get('title', ''),
                'mlConflicts': result.get('conflicts')
            }
            
            # Always update department and severity with ML predictions
            update_data['department'] = result['department']
            update_data['severity'] = result['severity']
            
            # Update title if ML generated one and original is empty/generic
            ml_title = result.get('title', '')
            current_title = job_data.get('title', '')
            
            print(f"Title processing:")
            print(f"  Current title: '{current_title}'")
            print(f"  ML generated title: '{ml_title}'")
            
            # Always update title if ML generated a valid one
            if ml_title and ml_title != 'No title' and not ml_title.startswith('Processing'):
                update_data['title'] = ml_title
                print(f"  ✅ Title updated to: '{ml_title}'")
            else:
                print(f"  ⏭️ Title not updated - ML title: '{ml_title}'")
                # If ML didn't generate a good title, create a simple one from description
                if description and (not current_title or current_title == 'Processing...'):
                    simple_title = ' '.join(description.split()[:4]) + '...'
                    update_data['title'] = simple_title
                    print(f"  📝 Created simple title: '{simple_title}'")
            
            update_result = db.reports.update_one(
                {'_id': ObjectId(report_id)},
                {'$set': update_data}
            )
            
            # Get the updated report to log
            updated_report = db.reports.find_one({'_id': ObjectId(report_id)})
            
            print(f"Successfully classified report {report_id}:")
            print(f"  Severity: {result['severity']}")
            print(f"  Department: {result['department']}")
            print(f"  Title: {result.get('title', 'No title')}")
            print(f"  Conflicts: {result.get('conflicts', 'None')}")
            print(f"Updated fields:")
            for key, value in update_data.items():
                print(f"  {key}: {value}")
            print(f"Update result - matched: {update_result.matched_count}, modified: {update_result.modified_count}")
            
            if updated_report:
                print(f"Final report state:")
                print(f"  ID: {updated_report.get('_id')}")
                print(f"  Title: {updated_report.get('title')}")
                print(f"  Department: {updated_report.get('department')}")
                print(f"  Severity: {updated_report.get('severity')}")
                print(f"  ML Title: {updated_report.get('mlTitle')}")
                print(f"  Original Description: {updated_report.get('description', '')[:50]}...")
            else:
                print("❌ No updated report returned from database")
            
            # Notify Node.js server about classification completion
            try:
                webhook_url = os.getenv('NODEJS_WEBHOOK_URL', 'http://localhost:3000/api/v1/reports/ml-webhook')
                
                # Convert MongoDB document to JSON serializable format
                serializable_report = None
                if updated_report:
                    serializable_report = {
                        '_id': str(updated_report['_id']),
                        'title': updated_report.get('title'),
                        'description': updated_report.get('description'),
                        'department': updated_report.get('department'),
                        'severity': updated_report.get('severity'),
                        'mlClassified': updated_report.get('mlClassified'),
                        'mlSeverity': updated_report.get('mlSeverity'),
                        'mlDepartment': updated_report.get('mlDepartment'),
                        'mlConfidence': updated_report.get('mlConfidence'),
                        'mlTitle': updated_report.get('mlTitle'),
                        'mlConflicts': updated_report.get('mlConflicts')
                    }
                
                webhook_payload = {
                    'reportId': report_id,
                    'classification': result,
                    'updatedReport': serializable_report
                }
                webhook_response = requests.post(webhook_url, json=webhook_payload, timeout=5)
                print(f"Webhook sent to Node.js server: {webhook_response.status_code}")
            except Exception as webhook_error:
                print(f"Failed to send webhook: {webhook_error}")
            
            print("=" * 50)
        else:
            print(f"ML service error for report {report_id}: {response.status_code}")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"Error processing classification job: {e}")

def worker_loop():
    """Main worker loop"""
    print("Starting ML classification worker...")
    print(f"Redis URL: {REDIS_URL}")
    print(f"MongoDB URI: {MONGO_URI}")
    print(f"ML Service URL: {ML_SERVICE_URL}")
    
    while True:
        try:
            # Check for jobs in Redis queue
            job_data = redis_client.blpop('ml_classification_queue', timeout=5)
            
            if job_data:
                print(f"Received job: {job_data}")
                job_json = job_data[1].decode('utf-8')
                job = json.loads(job_json)
                process_classification_job(job)
            else:
                # No jobs, sleep briefly
                print("No jobs in queue, waiting...")
                time.sleep(1)
                
        except KeyboardInterrupt:
            print("Worker stopped by user")
            break
        except Exception as e:
            print(f"Worker error: {e}")
            time.sleep(5)  # Wait before retrying

if __name__ == "__main__":
    worker_loop()
import cv2
import numpy as np
from firebase_admin import db, storage
from google.cloud import functions

@functions.background
def detect_blur(request):
    image_url = request.data['imageUrl']

    bucket = storage.bucket()
    blob = bucket.blob(image_url)
    image_data = blob.download_as_string()
    image = cv2.imdecode(np.frombuffer(image_data, np.uint8), cv2.IMREAD_COLOR)

    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    laplacian = cv2.Laplacian(gray, cv2.CV_64F).var()

    is_blurred = laplacian < 150

    return {'isBlurred': is_blurred}



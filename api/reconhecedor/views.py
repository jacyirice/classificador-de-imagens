import numpy as np
import tensorflow as tf

from PIL import Image, ImageOps
from django.conf import settings
from django.http.response import JsonResponse
from rest_framework.decorators import api_view
from rest_framework.parsers import MultiPartParser
from rest_framework.decorators import parser_classes

from .serializers import ImageSerializer


@api_view(['POST'])
@parser_classes([MultiPartParser])
def index(request):
    class_names = ['T-shirt/top', 'Trouser', 'Pullover', 'Dress', 'Coat',
                   'Sandal', 'Shirt', 'Sneaker', 'Bag', 'Ankle boot']
    context = {}
    serializer = ImageSerializer(data=request.data)
    if serializer.is_valid(raise_exception=True):
        model = tf.keras.models.load_model(settings.BASE_DIR / 'my_model.h5')
        img = Image.open(request.FILES['file'])
        img = ImageOps.grayscale(img)
        output_size = (28, 28)
        img.thumbnail(output_size)
        img.save(settings.BASE_DIR / 'grayscale-thumbnail.jpg')
        im2array = np.array(img)
        im2array = (np.expand_dims(im2array, 0))
        print(request.FILES['file'], img,
              img.width, img.height, im2array.shape)
        predictions_single = model.predict(im2array)
        print(predictions_single)
        predicted = class_names[np.argmax(predictions_single[0])]
        context['predicted'] = predicted
        context['precision'] = float(max(predictions_single[0]))
        return JsonResponse(context, status=200)

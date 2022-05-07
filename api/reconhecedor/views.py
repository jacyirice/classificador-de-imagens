import numpy as np
import tensorflow as tf

from PIL import Image
from django.conf import settings
from django.http.response import JsonResponse
from django.utils.translation import gettext_lazy as _
from rest_framework.decorators import api_view
from rest_framework.parsers import MultiPartParser
from rest_framework.decorators import parser_classes

from .serializers import ImageSerializer

@api_view(['POST'])
@parser_classes([MultiPartParser])
def index(request):
    class_names = [_('T-shirt/top'), _('Trouser'), _('Pullover'), _('Dress'), _('Coat'),
                   _('Sandal'), _('Shirt'), _('Sneaker'), _('Bag'), _('Ankle boot')]
    context = {}
    serializer = ImageSerializer(data=request.data)

    if serializer.is_valid(raise_exception=True):
        model = tf.keras.models.load_model(settings.BASE_DIR / 'my_model.h5')

        img = Image.open(serializer.validated_data['file'] ).convert('L')
        img = img.resize((28, 28))
        
        im2array = np.array(img) / 255.0
        im2array = (np.expand_dims(im2array, 0))

        predictions_single = model.predict(im2array)
        predicted = class_names[np.argmax(predictions_single[0])]

        context['predicted'] = predicted
        context['precision'] = float(max(predictions_single[0]))
        return JsonResponse(context, status=200)

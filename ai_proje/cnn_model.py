import tensorflow as tf
from tensorflow.keras import layers, models

def model_olustur(input_shape, num_classes):

    model = models.Sequential([
        
        layers.Rescaling(1./255, input_shape=input_shape),
        
        
        layers.Conv2D(32, 3, padding='same', activation='LeakyReLU'),
        layers.MaxPooling2D(),
        
        
        layers.Conv2D(64, 3, padding='same', activation='LeakyReLU'),
        layers.MaxPooling2D(),
        
        
        layers.Conv2D(128, 3, padding='same', activation='LeakyReLU'),
        layers.MaxPooling2D(),
        

        
        
        layers.Flatten(),
        layers.Dense(128, activation='relu'),
        layers.Dropout(0.5), 
        

        layers.Dense(num_classes, activation='softmax')
    ])
    
    return model
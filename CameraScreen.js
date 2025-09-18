// CameraScreen.js
import React, { useState, useRef } from 'react';
import { View, StyleSheet, Alert } from 'react-native';
import { Camera } from 'expo-camera';
import * as Location from 'expo-location';
import { ActivityIndicator, Text, Button } from 'react-native-paper';
import { API_URL } from './config';

export default function CameraScreen({ navigation }) {
  const [isProcessing, setIsProcessing] = useState(false);
  const [processMessage, setProcessMessage] = useState('');
  const cameraRef = useRef(null);

  const takePictureAndAnalyze = async () => {
    if (!cameraRef.current) return;
    setIsProcessing(true);

    try {
      setProcessMessage('Taking picture...');
      const photo = await cameraRef.current.takePictureAsync({ quality: 0.7 });

      setProcessMessage('Getting GPS coordinates...');
      const location = await Location.getCurrentPositionAsync({});
      const { latitude, longitude } = location.coords;

      setProcessMessage('Uploading to server...');
      const formData = new FormData();
      formData.append('image', {
        uri: photo.uri,
        name: 'sand_image.jpg',
        type: 'image/jpeg',
      });
      formData.append('latitude', latitude);
      formData.append('longitude', longitude);

      const response = await fetch(API_URL, {
        method: 'POST',
        body: formData,
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });

      if (!response.ok) {
        throw new Error(`Server returned an error: ${response.status} ${response.statusText}`);
      }

      const results = await response.json();
      navigation.replace('Results', { analysis: results });

    } catch (error) {
      console.error('Analysis failed:', error);
      Alert.alert(
        'Analysis Failed',
        `An error occurred during analysis. Details: ${error.message}`
      );
    } finally {
      setIsProcessing(false);
    }
  };

  if (isProcessing) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#0000ff" />
        <Text style={styles.loadingText}>{processMessage}</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Camera style={styles.camera} ref={cameraRef} />
      <View style={styles.buttonContainer}>
        <Button mode="contained" onPress={takePictureAndAnalyze}>
          Capture & Analyze
        </Button>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  camera: { flex: 1 },
  buttonContainer: { padding: 20, backgroundColor: 'transparent' },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    marginTop: 15,
    fontSize: 16,
    color: '#333',
    textAlign: 'center',
  },
});
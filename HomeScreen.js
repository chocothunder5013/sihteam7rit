// HomeScreen.js
import React, { useEffect } from 'react';
import { View, StyleSheet, Alert } from 'react-native';
import { Button, Text, Title } from 'react-native-paper';
import { Camera } from 'expo-camera';
import * as Location from 'expo-location';

export default function HomeScreen({ navigation }) {
  useEffect(() => {
    (async () => {
      const { status: cameraStatus } = await Camera.requestCameraPermissionsAsync();
      const { status: locationStatus } = await Location.requestForegroundPermissionsAsync();
      
      if (cameraStatus !== 'granted' || locationStatus !== 'granted') {
        Alert.alert('Permissions Required', 'Camera and location permissions are needed to analyze sand.');
      }
    })();
  }, []);

  const handleAnalyzePress = () => {
    navigation.navigate('Camera');
  };

  return (
    <View style={styles.container}>
      <Title style={styles.title}>Welcome to BeachGrainSense!</Title>
      <Text style={styles.instructions}>
        Press the button below to analyze a sand sample. Make sure you have a ₹5 coin for scale.
      </Text>
      <Button
        mode="contained"
        icon="camera"
        onPress={handleAnalyzePress}
        style={styles.button}
        contentStyle={styles.buttonContent}
        labelStyle={styles.buttonLabel}
      >
        Analyze Sand
      </Button>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
    backgroundColor: '#F5F5F5',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 10,
    color: '#333',
    textAlign: 'center',
  },
  instructions: {
    textAlign: 'center',
    marginBottom: 30,
    fontSize: 16,
    color: '#555',
  },
  button: {
    paddingVertical: 10,
  },
  buttonContent: {
    height: 50,
  },
  buttonLabel: {
    fontSize: 18,
  },
});
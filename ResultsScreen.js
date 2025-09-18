// ResultsScreen.js
import React from 'react';
import { View, StyleSheet } from 'react-native';
import { Card, Title, List, Text } from 'react-native-paper';

export default function ResultsScreen({ route }) {
  const { analysis } = route.params;

  return (
    <View style={styles.container}>
      <Card style={styles.card}>
        <Card.Content>
          <Title style={styles.header}>Analysis Complete!</Title>
          <List.Item
            title="Beach Classification:"
            description={analysis.beach_classification || 'N/A'}
            left={() => <List.Icon icon="map" />}
            titleStyle={styles.listItemTitle}
            descriptionStyle={styles.listItemDescription}
          />
          <List.Item
            title="Average Grain Size:"
            description={analysis.average_size_mm ? `${analysis.average_size_mm.toFixed(2)} mm` : 'N/A'}
            left={() => <List.Icon icon="ruler" />}
            titleStyle={styles.listItemTitle}
            descriptionStyle={styles.listItemDescription}
          />
          <List.Item
            title="Location:"
            description={`Lat: ${analysis.latitude.toFixed(4)}, Lon: ${analysis.longitude.toFixed(4)}`}
            left={() => <List.Icon icon="map-marker" />}
            titleStyle={styles.listItemTitle}
            descriptionStyle={styles.listItemDescription}
          />
        </Card.Content>
      </Card>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
    backgroundColor: '#F5F5F5',
    justifyContent: 'center',
  },
  card: {
    elevation: 4,
  },
  header: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 20,
    color: '#007AFF',
  },
  listItemTitle: {
    fontSize: 16,
    color: '#555',
  },
  listItemDescription: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
});
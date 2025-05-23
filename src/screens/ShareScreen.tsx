import React, { useState, useRef } from 'react';
import { ScrollView, Alert } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { RootStackParamList } from '../navigation/AppNavigator';
import { poems, Poem } from '../data/poetryData';
import { 
  SafeAreaContainer,
  ScreenContainer,
  PoemCard,
  Subtitle,
  BodyText,
  AuthorText,
  DateText,
  Input,
  TextArea,
  Button,
  ButtonText,
} from '../styles/styledComponents';
import { theme } from "../styles/theme";

type ShareScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Share'>;

const ShareScreen = () => {
  const navigation = useNavigation<ShareScreenNavigationProp>();
  const scrollRef = useRef<ScrollView>(null);
  const [localPoems, setLocalPoems] = useState<Poem[]>(poems);
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [author, setAuthor] = useState('');

  const handleSubmit = () => {
    if (!title.trim() || !content.trim()) {
      Alert.alert('Missing Information', 'Please provide both a title and content for your poem.');
      return;
    }

    const newPoem: Poem = {
      id: (localPoems.length + 1).toString(),
      title: title.trim(),
      content: content.trim(),
      author: author.trim() || 'Anonymous',
      date: new Date().toISOString().split('T')[0],
    };

    setLocalPoems([newPoem, ...localPoems]);
    setTitle('');
    setContent('');
    setAuthor('');

    // Scroll to top after submission
    scrollRef.current?.scrollTo({ y: 0, animated: true });

    Alert.alert('Success', 'Your poem has been added!');
  };

  return (
    <SafeAreaContainer>
      <ScrollView ref={scrollRef} keyboardShouldPersistTaps="handled">
        <ScreenContainer>
          <Subtitle>Write Your Poem</Subtitle>
          
          <Input
            placeholder="Title"
            placeholderTextColor={theme.colors.lightText}
            value={title}
            onChangeText={setTitle}
          />

          <TextArea
            placeholder="Your poem..."
            placeholderTextColor={theme.colors.lightText}
            value={content}
            onChangeText={setContent}
            multiline
          />

          <Input
            placeholder="Your name (optional)"
            placeholderTextColor={theme.colors.lightText}
            value={author}
            onChangeText={setAuthor}
          />

          <Button onPress={handleSubmit}>
            <ButtonText>Share Poem</ButtonText>
          </Button>

          <Subtitle style={{ marginTop: 20 }}>Community Poems</Subtitle>

          {localPoems.length === 0 ? (
            <BodyText>No poems shared yet. Yours could be the first.</BodyText>
          ) : (
            localPoems.map((poem) => (
              <PoemCard key={poem.id}>
                <Subtitle>{poem.title}</Subtitle>
                <BodyText>{poem.content}</BodyText>
                <AuthorText>{poem.author}</AuthorText>
                <DateText>{poem.date}</DateText>
              </PoemCard>
            ))
          )}
        </ScreenContainer>
      </ScrollView>
    </SafeAreaContainer>
  );
};

export default ShareScreen;
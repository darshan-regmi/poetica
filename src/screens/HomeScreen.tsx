/**
 * The HomeScreen component in a TypeScript React application displays a random quote from poetryData
 * and allows the user to refresh the quote or navigate to the Share screen.
 * @returns The `HomeScreen` component is being returned. It is a functional component in React that
 * displays a random quote along with the author's name. The component also includes a button to
 * refresh the quote and a button to navigate to the 'Share' screen. The `HomeScreen` component is
 * wrapped in various styled components for layout and styling purposes.
 */
import React, { useState, useEffect } from 'react';
import { TouchableOpacity } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { RootStackParamList } from '../navigation/AppNavigator';
import { getRandomQuote, Quote } from '../data/poetryData';
import { 
  SafeAreaContainer,
  ScreenContainer,
  CenteredContainer,
  QuoteCard,
  QuoteText,
  AuthorText,
  Button,
  ButtonText,
} from '../styles/styledComponents';
import { Feather } from '@expo/vector-icons';
import { theme } from '../styles/theme';

type HomeScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Home'>;

const HomeScreen = () => {
  const navigation = useNavigation<HomeScreenNavigationProp>();
  const [quote, setQuote] = useState<Quote>(getRandomQuote());

  const refreshQuote = () => {
    setQuote(getRandomQuote());
  };

  useEffect(() => {
    // Refresh quote when screen comes into focus
    const unsubscribe = navigation.addListener('focus', () => {
      refreshQuote();
    });

    return unsubscribe;
  }, [navigation]);

  return (
    <SafeAreaContainer>
      <ScreenContainer>
        <CenteredContainer>
          <QuoteCard>
            <QuoteText>{quote.text}</QuoteText>
            <AuthorText>— {quote.author}</AuthorText>
          </QuoteCard>
          
          <TouchableOpacity 
            onPress={refreshQuote}
            style={{ 
              padding: theme.spacing.md, 
              marginVertical: theme.spacing.md 
            }}
          >
            <Feather name="refresh-cw" size={24} color={theme.colors.primary} />
          </TouchableOpacity>
          
          <Button onPress={() => navigation.navigate('Share')}>
            <ButtonText>Share Your Poem</ButtonText>
          </Button>
        </CenteredContainer>
      </ScreenContainer>
    </SafeAreaContainer>
  );
};

export default HomeScreen;

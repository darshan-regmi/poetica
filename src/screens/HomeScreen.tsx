/**
 * The HomeScreen component in a TypeScript React application displays a random quote from poetryData
 * and allows the user to refresh the quote or navigate to the Share screen.
 * @returns The `HomeScreen` component is being returned. It is a functional component in React that
 * displays a random quote along with the author's name. The component also includes a button to
 * refresh the quote and a button to navigate to the 'Share' screen. The `HomeScreen` component is
 * wrapped in various styled components for layout and styling purposes.
 */
import React, { useState, useEffect, useRef } from 'react';
import { TouchableOpacity, Animated, Easing, View, StyleSheet } from 'react-native';
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

interface MoodFilter {
  name: string;
  icon: string;
}

const HomeScreen = () => {
  const navigation = useNavigation<HomeScreenNavigationProp>();
  const [quote, setQuote] = useState<Quote>(getRandomQuote());
  const [isLoading, setIsLoading] = useState<boolean>(false);
  
  // Animation values
  const spinValue = useRef(new Animated.Value(0)).current;
  const fadeAnim = useRef(new Animated.Value(1)).current;
  const buttonScale = useRef(new Animated.Value(1)).current;

  // Refresh quote with animation
  const refreshQuote = () => {
    // Start loading state
    setIsLoading(true);
    
    // Fade out current quote
    Animated.timing(fadeAnim, {
      toValue: 0,
      duration: 300,
      useNativeDriver: true,
    }).start(() => {
      // Update quote while it's invisible
      setQuote(getRandomQuote());
      
      // Fade in new quote
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 500,
        useNativeDriver: true,
      }).start(() => {
        setIsLoading(false);
      });
    });
    
    // Animate refresh icon
    Animated.timing(spinValue, {
      toValue: 1,
      duration: 800,
      easing: Easing.linear,
      useNativeDriver: true,
    }).start(() => {
      spinValue.setValue(0);
    });
  };
  
  // Button press animation
  const onPressIn = () => {
    Animated.spring(buttonScale, {
      toValue: 0.95,
      useNativeDriver: true,
    }).start();
  };
  
  const onPressOut = () => {
    Animated.spring(buttonScale, {
      toValue: 1,
      friction: 5,
      tension: 40,
      useNativeDriver: true,
    }).start();
  };

  useEffect(() => {
    // Refresh quote when screen comes into focus
    const unsubscribe = navigation.addListener('focus', () => {
      refreshQuote();
    });

    return unsubscribe;
  }, [navigation]);
  
  // Create the spin interpolation function for refresh icon
  const spin = spinValue.interpolate({
    inputRange: [0, 1],
    outputRange: ['0deg', '360deg'],
  });

  return (
    <SafeAreaContainer>
      <ScreenContainer>
        <CenteredContainer>
          {/* Quote Card with Animated Fade */}
          <Animated.View style={{ opacity: fadeAnim, width: '100%' }}>
            <QuoteCard style={styles.enhancedQuoteCard}>
              <QuoteText style={styles.enhancedQuoteText}>{quote.text}</QuoteText>
              <AuthorText style={styles.enhancedAuthorText}>— {quote.author}</AuthorText>
            </QuoteCard>
          </Animated.View>
          
          {/* Refresh Button with Tooltip and Animation */}
          <View style={styles.refreshContainer}>
            <TouchableOpacity 
              onPress={refreshQuote}
              style={styles.refreshButton}
              accessibilityLabel="Refresh quote"
              accessibilityHint="Tap to get a new inspirational quote"
            >
              <Animated.View style={{ transform: [{ rotate: spin }] }}>
                <Feather name="refresh-cw" size={24} color={theme.colors.primary} />
              </Animated.View>
              <View style={styles.tooltipContainer}>
                <View style={styles.tooltip}>
                  <AuthorText style={styles.tooltipText}>Inspire me again</AuthorText>
                </View>
              </View>
            </TouchableOpacity>
          </View>
          
          {/* Enhanced Share Button with Animation and Icon */}
          <Animated.View style={{
            transform: [{ scale: buttonScale }],
            width: '100%',
            alignItems: 'center'
          }}>
            <Button 
              onPress={() => navigation.navigate('Share')}
              onPressIn={onPressIn}
              onPressOut={onPressOut}
              style={styles.enhancedButton}
              accessibilityLabel="Share your poem"
              accessibilityHint="Tap to share your own poem"
            >
              <View style={styles.buttonContent}>
                <Feather name="edit-3" size={18} color="white" style={styles.buttonIcon} />
                <ButtonText style={styles.enhancedButtonText}>Share Your Poem</ButtonText>
              </View>
            </Button>
          </Animated.View>
        </CenteredContainer>
      </ScreenContainer>
    </SafeAreaContainer>
  );
};

// Additional styles for enhanced UI
const styles = StyleSheet.create({
  enhancedQuoteCard: {
    backgroundColor: 'rgba(57, 62, 70, 0.9)',  // Slightly more contrast
    borderLeftWidth: 5,  // Thicker accent border
    minHeight: 220,  // Slightly taller
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 8,
    elevation: 6,
  },
  enhancedQuoteText: {
    fontSize: theme.fontSizes.lg,  // Larger font
    lineHeight: 28,  // Increased line height
    letterSpacing: 0.3,  // Slight letter spacing
    color: '#F5F5F5',  // Brighter text for better contrast
  },
  enhancedAuthorText: {
    marginTop: theme.spacing.md,  // More spacing
    color: theme.colors.accent,  // Better contrast
    fontWeight: '500',  // Slightly bolder
  },
  refreshContainer: {
    position: 'relative',
    alignItems: 'center',
    marginVertical: theme.spacing.md,
  },
  refreshButton: {
    padding: theme.spacing.md,
    borderRadius: 50,  // Circular button
    backgroundColor: 'rgba(57, 62, 70, 0.3)',  // Subtle background
  },
  tooltipContainer: {
    position: 'absolute',
    top: -theme.spacing.xl,
    width: 120,
    alignItems: 'center',
    opacity: 0.8,  // Subtle appearance
  },
  tooltip: {
    backgroundColor: theme.colors.card,
    paddingVertical: theme.spacing.xs,
    paddingHorizontal: theme.spacing.sm,
    borderRadius: theme.borderRadius.sm,
  },
  tooltipText: {
    fontSize: theme.fontSizes.xs,
    color: theme.colors.accent,
  },
  enhancedButton: {
    backgroundColor: theme.colors.primary,
    paddingVertical: theme.spacing.md,
    paddingHorizontal: theme.spacing.xl,
    borderRadius: theme.borderRadius.md,
    shadowColor: theme.colors.primary,
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.3,
    shadowRadius: 5,
    elevation: 5,
    width: '80%',  // Wider button
  },
  buttonContent: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  buttonIcon: {
    marginRight: theme.spacing.sm,
  },
  enhancedButtonText: {
    fontSize: theme.fontSizes.md,
    fontWeight: '600',
    letterSpacing: 0.5,
  },
});

export default HomeScreen;

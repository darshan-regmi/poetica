import React, { useState } from 'react';
import { ScrollView, Alert, Image, StyleSheet, TouchableOpacity, KeyboardAvoidingView, Platform } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { RootStackParamList } from '../navigation/AppNavigator';
import { 
  SafeAreaContainer,
  ScreenContainer,
  CenteredContainer,
  Title,
  Subtitle,
  BodyText,
  Input,
  Button,
  ButtonText,
  Divider
} from '../styles/styledComponents';
import { theme } from '../styles/theme';

type LoginScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Home'>;

const LoginScreen = () => {
  const navigation = useNavigation<LoginScreenNavigationProp>();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLogin, setIsLogin] = useState(true);

  const handleAuth = () => {
    // Basic validation
    if (!email.trim() || !password.trim()) {
      Alert.alert('Missing Information', 'Please enter both email and password.');
      return;
    }

    if (!isValidEmail(email)) {
      Alert.alert('Invalid Email', 'Please enter a valid email address.');
      return;
    }

    if (password.length < 6) {
      Alert.alert('Invalid Password', 'Password must be at least 6 characters long.');
      return;
    }

    // In a real app, you would implement actual authentication here
    // For demo purposes, we'll just navigate to Home
    Alert.alert('Success', isLogin ? 'Login successful!' : 'Account created successfully!', [
      { text: 'OK', onPress: () => navigation.navigate('Home') }
    ]);
  };

  const isValidEmail = (email: string) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  };

  const toggleAuthMode = () => {
    setIsLogin(!isLogin);
    // Clear fields when switching modes
    setEmail('');
    setPassword('');
  };

  return (
    <SafeAreaContainer>
      <KeyboardAvoidingView 
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={{ flex: 1 }}
      >
        <ScrollView 
          contentContainerStyle={{ flexGrow: 1 }}
          keyboardShouldPersistTaps="handled"
        >
          <CenteredContainer>
            {/* App Logo */}
            <Image 
              source={require('../../assets/logo3.png')} 
              style={styles.logo}
              resizeMode="contain"
            />
            
            <Subtitle>{isLogin ? 'Sign in to your account' : 'Create a new account'}</Subtitle>
            
            <Input
              placeholder="Email"
              placeholderTextColor={theme.colors.lightText}
              value={email}
              onChangeText={setEmail}
              keyboardType="email-address"
              autoCapitalize="none"
              style={styles.input}
            />

            <Input
              placeholder="Password"
              placeholderTextColor={theme.colors.lightText}
              value={password}
              onChangeText={setPassword}
              secureTextEntry
              style={styles.input}
            />

            {isLogin && (
              <TouchableOpacity style={styles.forgotPassword}>
                <BodyText style={styles.forgotPasswordText}>Forgot password?</BodyText>
              </TouchableOpacity>
            )}

            <Button onPress={handleAuth} style={styles.button}>
              <ButtonText>{isLogin ? 'Sign In' : 'Sign Up'}</ButtonText>
            </Button>

            <Divider style={styles.divider} />

            <BodyText style={styles.toggleText}>
              {isLogin ? "Don't have an account?" : 'Already have an account?'}
            </BodyText>
            
            <TouchableOpacity onPress={toggleAuthMode} style={styles.toggleButton}>
              <BodyText style={styles.toggleButtonText}>
                {isLogin ? 'Sign Up' : 'Sign In'}
              </BodyText>
            </TouchableOpacity>
          </CenteredContainer>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaContainer>
  );
};

const styles = StyleSheet.create({
  logo: {
    width: 120,
    height: 120,
    marginBottom: theme.spacing.md,
  },
  input: {
    width: '100%',
    maxWidth: 350,
  },
  button: {
    width: '100%',
    maxWidth: 350,
    marginTop: theme.spacing.lg,
  },
  forgotPassword: {
    alignSelf: 'flex-end',
    marginRight: theme.spacing.md,
    marginTop: theme.spacing.xs,
    maxWidth: 350,
    width: '100%',
  },
  forgotPasswordText: {
    color: theme.colors.primary,
    fontSize: theme.fontSizes.sm,
    textAlign: 'right',
  },
  divider: {
    width: '80%',
    maxWidth: 350,
  },
  toggleText: {
    marginTop: theme.spacing.md,
    textAlign: 'center',
  },
  toggleButton: {
    marginTop: theme.spacing.sm,
    padding: theme.spacing.sm,
  },
  toggleButtonText: {
    color: theme.colors.primary,
    fontWeight: 'bold',
  }
});

export default LoginScreen;
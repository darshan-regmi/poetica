/* The code you provided is a set of styled components in a React Native project using
styled-components library. Here's a breakdown of what the code is doing: */
import styled from 'styled-components/native';
import { Platform } from 'react-native';
import { theme } from './theme';

// Unified shadow support
const shadow = Platform.select({
  ios: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 10,
  },
  android: {
    elevation: 4,
  },
});

// Container components
export const SafeAreaContainer = styled.SafeAreaView`
  flex: 1;
  background-color: ${theme.colors.background};
`;

export const ScreenContainer = styled.View`
  flex: 1;
  padding: ${theme.spacing.md}px;
  background-color: ${theme.colors.background};
`;

export const CenteredContainer = styled.View`
  flex: 2;
  justify-content: center;
  align-items: center;
  padding: ${theme.spacing.md}px;
`;

// Card components
export const Card = styled.View`
  background-color: ${theme.colors.card};
  border-radius: ${theme.borderRadius.lg}px;
  padding: ${theme.spacing.lg}px;
  margin-vertical: ${theme.spacing.md}px;
  ${shadow}
`;

export const QuoteCard = styled(Card)`
  min-height: 200px;
  justify-content: center;
  border-left-width: 4px;
  border-left-color: ${theme.colors.accent};
`;

export const PoemCard = styled(Card)`
  min-height: 150px;
  border-top-width: 4px;
  border-top-color: ${theme.colors.primary};
`;

// Text components
export const Title = styled.Text`
  font-size: ${theme.fontSizes.xxl}px;
  color: ${theme.colors.text};
  font-weight: bold;
  text-align: center;
  margin-vertical: ${theme.spacing.md}px;
`;

export const Subtitle = styled.Text`
  font-size: ${theme.fontSizes.lg}px;
  color: ${theme.colors.text};
  font-weight: 500;
  margin-vertical: ${theme.spacing.sm}px;
`;

export const BodyText = styled.Text`
  font-size: ${theme.fontSizes.md}px;
  color: ${theme.colors.text};
  line-height: 24px;
`;

export const QuoteText = styled(BodyText)`
  font-style: italic;
  margin-bottom: ${theme.spacing.md}px;
  text-align: center;
`;

export const AuthorText = styled.Text`
  font-size: ${theme.fontSizes.sm}px;
  color: ${theme.colors.lightText};
  text-align: right;
  margin-top: ${theme.spacing.sm}px;
`;

export const DateText = styled.Text`
  font-size: ${theme.fontSizes.xs}px;
  color: ${theme.colors.lightText};
  margin-top: ${theme.spacing.xs}px;
`;

// Input components
export const Input = styled.TextInput`
  background-color: ${theme.colors.card};
  padding: ${theme.spacing.md}px;
  border-radius: ${theme.borderRadius.md}px;
  margin-vertical: ${theme.spacing.sm}px;
  font-size: ${theme.fontSizes.md}px;
  color: ${theme.colors.text};
  border-width: 1px;
  border-color: ${theme.colors.border};
`;

export const TextArea = styled(Input)`
  min-height: 150px;
  text-align-vertical: top;
`;

// Button components
export const Button = styled.TouchableOpacity.attrs({
  activeOpacity: 0.7,
})`
  background-color: ${theme.colors.primary};
  padding-vertical: ${theme.spacing.md}px;
  padding-horizontal: ${theme.spacing.lg}px;
  border-radius: ${theme.borderRadius.md}px;
  align-items: center;
  justify-content: center;
  margin-vertical: ${theme.spacing.md}px;
`;

export const ButtonText = styled.Text`
  color: white;
  font-size: ${theme.fontSizes.md}px;
  font-weight: 500;
`;

// Header components
export const HeaderContainer = styled.View`
  padding-vertical: ${theme.spacing.md}px;
  align-items: center;
  justify-content: center;
  border-bottom-width: 1px;
  border-bottom-color: ${theme.colors.border};
`;

export const HeaderTitle = styled.Text`
  font-size: ${theme.fontSizes.xl}px;
  color: ${theme.colors.text};
  font-weight: bold;
`;

// Extra UI
export const Divider = styled.View`
  height: 1px;
  background-color: ${theme.colors.border};
  margin-vertical: ${theme.spacing.md}px;
`;

export const Overlay = styled.View`
  position: absolute;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  background-color: rgba(0, 0, 0, 0.3);
`;
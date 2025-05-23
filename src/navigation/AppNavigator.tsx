/**
 * The code defines a navigation stack for a React Native app with two screens, HomeScreen and
 * ShareScreen, using React Navigation.
 * @property Home - The code you provided sets up a basic navigation stack using React Navigation in a
 * React Native application.
 * @property Share - The `Share` property in the code snippet refers to a screen in the app navigation.
 * When the user navigates to the `Share` screen, the `ShareScreen` component will be rendered in the
 * app. This allows users to interact with the content or functionality specific to the `Share` screen
 */
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import HomeScreen from '../screens/HomeScreen';
import ShareScreen from '../screens/ShareScreen';
import { theme } from '../styles/theme';
import { HeaderTitle } from '../styles/styledComponents';

export type RootStackParamList = {
  Home: undefined;
  Share: undefined;
};

const Stack = createStackNavigator<RootStackParamList>();

const AppNavigator = () => {
  return (
    <NavigationContainer>
      <Stack.Navigator
        initialRouteName="Home"
        screenOptions={{
          headerStyle: {
            backgroundColor: theme.colors.background,
            elevation: 0,
            shadowOpacity: 0,
            borderBottomWidth: 1,
            borderBottomColor: theme.colors.border,
          },
          headerTitleAlign: 'center',
          headerTitle: () => <HeaderTitle>Poetica</HeaderTitle>,
          cardStyle: { backgroundColor: theme.colors.background },
        }}
      >
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="Share" component={ShareScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
};

export default AppNavigator;

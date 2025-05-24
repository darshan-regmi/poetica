import React, { useEffect } from 'react';
import {
  StyleSheet,
  TouchableOpacity,
  View,
  Text,
  Image,
  StatusBar,
  Platform,
  Animated,
  useWindowDimensions,
  SafeAreaView
} from 'react-native';
import { useNavigation, useIsFocused } from '@react-navigation/native';
import { Ionicons, Feather, MaterialCommunityIcons } from '@expo/vector-icons';
import { theme } from '../styles/theme';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

interface CustomHeaderProps {
  title?: string;
  showBackButton?: boolean;
  onBackPress?: () => void;
  transparent?: boolean;
}

const CustomHeader: React.FC<CustomHeaderProps> = ({
  title,
  showBackButton = false,
  onBackPress,
  transparent = false
}) => {
  const navigation = useNavigation();
  const { width } = useWindowDimensions();
  const insets = useSafeAreaInsets();
  const isFocused = useIsFocused();
  
  // Animation values
  const opacity = React.useRef(new Animated.Value(0)).current;
  const translateY = React.useRef(new Animated.Value(-10)).current;
  
  useEffect(() => {
    StatusBar.setBarStyle(transparent ? 'light-content' : 'dark-content');
    if (Platform.OS === 'android') {
      StatusBar.setBackgroundColor(transparent ? 'transparent' : theme.colors.background);
      StatusBar.setTranslucent(transparent);
    }
    
    // Animate header on mount
    Animated.parallel([
      Animated.timing(opacity, {
        toValue: 1,
        duration: 300,
        useNativeDriver: true
      }),
      Animated.timing(translateY, {
        toValue: 0,
        duration: 300,
        useNativeDriver: true
      })
    ]).start();
  }, [transparent, isFocused]);
  
  const handleBackPress = () => {
    if (onBackPress) {
      onBackPress();
    } else if (navigation.canGoBack()) {
      navigation.goBack();
    }
  };

  return (
    <Animated.View
      style={[
        styles.container,
        {
          paddingTop: insets.top > 0 ? insets.top : 10,
          backgroundColor: transparent
            ? "transparent"
            : theme.colors.background,
          shadowOpacity: transparent ? 0 : 0.1,
          opacity,
          transform: [{ translateY }],
        },
      ]}
    >
      {/* Left Section: Back Button or Logo */}
      <View style={styles.leftSection}>
        {showBackButton ? (
          <TouchableOpacity
            style={styles.backButton}
            onPress={handleBackPress}
            hitSlop={{ top: 15, bottom: 15, left: 15, right: 15 }}
          >
            <Ionicons
              name="chevron-back"
              size={28}
              color={transparent ? theme.colors.accent : theme.colors.primary}
            />
            {title && width > 360 && (
              <Text
                style={[
                  styles.backText,
                  {
                    color: transparent
                      ? theme.colors.accent
                      : theme.colors.text,
                  },
                ]}
                numberOfLines={1}
              >
                Back
              </Text>
            )}
          </TouchableOpacity>
        ) : (
          <Image
            source={require("../../assets/logo3.png")}
            style={styles.logo}
            resizeMode="contain"
          />
        )}
      </View>

      {/* Middle Section: Title (if provided) */}
      {title && !showBackButton && (
        <View style={styles.titleContainer}>
          <Text
            style={[
              styles.title,
              { color: transparent ? theme.colors.accent : theme.colors.text },
            ]}
            numberOfLines={1}
          >
            {title}
          </Text>
        </View>
      )}

      {/* Right Section: Icons */}
      <View style={styles.rightSection}>
        {/* Search Icon */}
        <TouchableOpacity
          style={styles.iconButton}
          onPress={() => console.log("Search pressed")}
        >
          <Feather
            name="search"
            marginTop={5}
            size={20}
            height={20}
            color={theme.colors.primary}
          />
        </TouchableOpacity>

        {/* Notifications Icon with Badge */}
        <TouchableOpacity
          style={styles.iconButton}
          onPress={() => console.log("Notifications pressed")}
        >
          <View>
            <Feather
              name="bell"
              marginTop={5}
              size={20}
              height={20}
              color={theme.colors.primary}
            />
            <View style={styles.notificationBadge}>
              <Text style={styles.badgeText}>3</Text>
            </View>
          </View>
        </TouchableOpacity>

        {/* Settings Icon */}
        <TouchableOpacity
          style={styles.iconButton}
          onPress={() => {
            navigation.navigate("Settings" as never);
          }}
        >
          <Ionicons
            name="settings-outline"
            marginTop={5}
            size={20}
            height={20}
            color={theme.colors.primary}
          />
        </TouchableOpacity>

        {/* Profile Avatar */}
        <TouchableOpacity
          style={styles.avatarButton}
          onPress={() => {
            navigation.navigate("Profile" as never);
          }}
        >
          <Image
            source={require("../../assets/image.png")}
            style={styles.avatar}
          />
          <View style={styles.onlineIndicator} />
        </TouchableOpacity>
      </View>
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  container: {
    height: Platform.OS === 'ios' ? 90 : 70,
    paddingHorizontal: theme.spacing.md,
    paddingBottom: 10,
    flexDirection: 'row',
    alignItems: 'flex-end',
    justifyContent: 'space-between',
    backgroundColor: theme.colors.background,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 5,
    zIndex: 100,
  },
  leftSection: {
    flex: 1,
    alignItems: 'flex-start',
    justifyContent: 'center',
  },
  logo: {
    width: 150,
    height: 30,
    resizeMode: 'contain',
  },
  logoText: {
    fontSize: 22,
    fontWeight: 'bold',
    color: theme.colors.primary,
    letterSpacing: 1,
  },
  backButton: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  backText: {
    fontSize: 16,
    marginLeft: 2,
    fontWeight: '500',
    color: theme.colors.text,
  },
  titleContainer: {
    position: 'absolute',
    left: 0,
    right: 0,
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: -1,
  },
  title: {
    fontSize: 18,
    fontWeight: '600',
    color: theme.colors.text,
  },
  rightSection: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'flex-end',
    minWidth: 120,
  },
  iconButton: {
    marginHorizontal: 10,
    padding: 5,
  },
  avatarButton: {
    marginLeft: 10,
    position: 'relative',
  },
  avatar: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: theme.colors.secondary,
    borderWidth: 2,
    borderColor: theme.colors.background,
  },
  notificationBadge: {
    position: 'absolute',
    top: -4,
    right: -4,
    backgroundColor: '#E57373',
    borderRadius: 8,
    minWidth: 16,
    height: 16,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 3,
    borderWidth: 1,
    borderColor: theme.colors.background,
  },
  badgeText: {
    color: theme.colors.accent,
    fontSize: 10,
    fontWeight: 'bold',
  },
  onlineIndicator: {
    position: 'absolute',
    bottom: 0,
    right: 0,
    width: 12,
    height: 12,
    borderRadius: 6,
    backgroundColor: '#4CAF50',
    borderWidth: 2,
    borderColor: theme.colors.background,
  },
});

export default CustomHeader;

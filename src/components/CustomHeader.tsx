import React, { useEffect, useState, useRef } from 'react';
import {
  StyleSheet,
  TouchableOpacity,
  View,
  Text,
  Image,
  StatusBar,
  Platform,
  Animated,
  Easing,
  Modal,
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

interface QuickAction {
  icon: string;
  label: string;
  onPress: () => void;
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
  
  // State for profile drawer
  const [profileDrawerVisible, setProfileDrawerVisible] = useState(false);
  
  // Animation values
  const opacity = useRef(new Animated.Value(0)).current;
  const translateY = useRef(new Animated.Value(-10)).current;
  const logoRotate = useRef(new Animated.Value(0)).current;
  const notificationBounce = useRef(new Animated.Value(1)).current;
  const profileScale = useRef(new Animated.Value(1)).current;
  
  // Define quick actions for profile drawer
  const quickActions: QuickAction[] = [
    {
      icon: 'edit-3',
      label: 'Write Poem',
      onPress: () => {
        setProfileDrawerVisible(false);
        navigation.navigate('Share' as never);
      }
    },
    {
      icon: 'bookmark',
      label: 'My Library',
      onPress: () => {
        setProfileDrawerVisible(false);
        console.log('Navigate to library');
      }
    },
    {
      icon: 'user',
      label: 'Profile',
      onPress: () => {
        setProfileDrawerVisible(false);
        navigation.navigate('Profile' as never);
      }
    },
    {
      icon: 'settings',
      label: 'Settings',
      onPress: () => {
        setProfileDrawerVisible(false);
        navigation.navigate('Settings' as never);
      }
    }
  ];
  
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
    
    // Animate logo on focus
    if (isFocused && !showBackButton) {
      Animated.sequence([
        Animated.timing(logoRotate, {
          toValue: 0.05,
          duration: 150,
          useNativeDriver: true,
          easing: Easing.linear
        }),
        Animated.timing(logoRotate, {
          toValue: -0.05,
          duration: 300,
          useNativeDriver: true,
          easing: Easing.linear
        }),
        Animated.timing(logoRotate, {
          toValue: 0,
          duration: 150,
          useNativeDriver: true,
          easing: Easing.linear
        })
      ]).start();
    }
    
    // Animate notification badge
    const bounceAnimation = Animated.sequence([
      Animated.timing(notificationBounce, {
        toValue: 1.3,
        duration: 300,
        useNativeDriver: true,
        easing: Easing.bounce
      }),
      Animated.timing(notificationBounce, {
        toValue: 1,
        duration: 300,
        useNativeDriver: true
      })
    ]);
    
    // Run bounce animation every 5 seconds
    const interval = setInterval(() => {
      bounceAnimation.start();
    }, 5000);
    
    return () => clearInterval(interval);
  }, [transparent, isFocused]);
  
  const handleBackPress = () => {
    if (onBackPress) {
      onBackPress();
    } else if (navigation.canGoBack()) {
      navigation.goBack();
    }
  };
  
  // Handle profile press with animation
  const handleProfilePress = () => {
    Animated.sequence([
      Animated.timing(profileScale, {
        toValue: 0.9,
        duration: 100,
        useNativeDriver: true
      }),
      Animated.timing(profileScale, {
        toValue: 1,
        duration: 100,
        useNativeDriver: true
      })
    ]).start();
    
    setProfileDrawerVisible(true);
  };
  
  // Create rotation interpolation for logo
  const logoRotation = logoRotate.interpolate({
    inputRange: [-0.05, 0, 0.05],
    outputRange: ['-5deg', '0deg', '5deg']
  });

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
            <Animated.View style={[styles.notificationBadge, { transform: [{ scale: notificationBounce }] }]}>
            </Animated.View>
          </View>
        </TouchableOpacity>

        {/* Profile Avatar */}
        <TouchableOpacity
          style={styles.avatarButton}
          onPress={handleProfilePress}
          onLongPress={handleProfilePress}
          accessibilityLabel="Profile menu"
          accessibilityHint="Tap to open profile menu with quick actions"
        >
          <Animated.Image
            source={require("../../assets/image.png")}
            style={[styles.avatar, { transform: [{ scale: profileScale }] }]}
          />
          <View style={styles.onlineIndicator} />
        </TouchableOpacity>
      </View>
      
      {/* Profile Quick Actions Drawer */}
      <Modal
        visible={profileDrawerVisible}
        transparent={true}
        animationType="fade"
        onRequestClose={() => setProfileDrawerVisible(false)}
      >
        <TouchableOpacity 
          style={styles.modalOverlay}
          activeOpacity={1}
          onPress={() => setProfileDrawerVisible(false)}
        >
          <View style={[styles.profileDrawer, { top: insets.top + 70 }]}>
            <View style={styles.drawerHeader}>
              <Image
                source={require("../../assets/image.png")}
                style={styles.drawerAvatar}
              />
              <View style={styles.drawerUserInfo}>
                <Text style={styles.drawerUserName}>Darshan Regmi</Text>
                <Text style={styles.drawerUserStatus}>Poet & Writer</Text>
              </View>
            </View>
            
            <View style={styles.drawerDivider} />
            
            {quickActions.map((action, index) => (
              <TouchableOpacity 
                key={index} 
                style={styles.drawerAction}
                onPress={action.onPress}
              >
                <Feather name={action.icon as any} size={18} color={theme.colors.primary} />
                <Text style={styles.drawerActionText}>{action.label}</Text>
              </TouchableOpacity>
            ))}
          </View>
        </TouchableOpacity>
      </Modal>
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
  // Profile drawer styles
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
  },
  profileDrawer: {
    position: 'absolute',
    right: theme.spacing.md,
    width: 220,
    backgroundColor: theme.colors.background,
    borderRadius: theme.borderRadius.md,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 5 },
    shadowOpacity: 0.3,
    shadowRadius: 10,
    elevation: 10,
    padding: theme.spacing.md,
  },
  drawerHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: theme.spacing.md,
  },
  drawerAvatar: {
    width: 40,
    height: 40,
    borderRadius: 20,
    marginRight: theme.spacing.md,
  },
  drawerUserInfo: {
    flex: 1,
  },
  drawerUserName: {
    fontSize: theme.fontSizes.md,
    fontWeight: '600',
    color: theme.colors.text,
  },
  drawerUserStatus: {
    fontSize: theme.fontSizes.xs,
    color: theme.colors.lightText,
    marginTop: 2,
  },
  drawerDivider: {
    height: 1,
    backgroundColor: theme.colors.border,
    marginVertical: theme.spacing.sm,
  },
  drawerAction: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: theme.spacing.sm,
    marginVertical: 2,
  },
  drawerActionText: {
    marginLeft: theme.spacing.md,
    fontSize: theme.fontSizes.md,
    color: theme.colors.text,
  },
});

export default CustomHeader;

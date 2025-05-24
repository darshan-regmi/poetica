import React from 'react';
import { StyleSheet, Text, View, TouchableOpacity, ScrollView, Switch } from 'react-native';
import { Ionicons, Feather } from '@expo/vector-icons';
import { theme } from '../styles/theme';
import { 
  SafeAreaContainer,
  ScreenContainer,
} from '../styles/styledComponents';

const SettingsScreen = () => {
  const [darkMode, setDarkMode] = React.useState(true);
  const [notifications, setNotifications] = React.useState(true);
  
  return (
    <SafeAreaContainer>
      <ScreenContainer>
        <ScrollView style={styles.container} showsVerticalScrollIndicator={false}>
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Appearance</Text>
            
            <View style={styles.settingRow}>
              <View style={styles.settingInfo}>
                <Ionicons name="moon-outline" size={22} color={theme.colors.primary} />
                <Text style={styles.settingText}>Dark Mode</Text>
              </View>
              <Switch
                value={darkMode}
                onValueChange={setDarkMode}
                trackColor={{ false: theme.colors.border, true: theme.colors.primary }}
                thumbColor={theme.colors.accent}
              />
            </View>
            
            <View style={styles.settingRow}>
              <View style={styles.settingInfo}>
                <Ionicons name="text-outline" size={22} color={theme.colors.primary} />
                <Text style={styles.settingText}>Font Size</Text>
              </View>
              <View style={styles.fontSizeButtons}>
                <TouchableOpacity style={styles.fontSizeButton}>
                  <Text style={styles.fontSizeButtonText}>A-</Text>
                </TouchableOpacity>
                <TouchableOpacity style={[styles.fontSizeButton, styles.fontSizeButtonActive]}>
                  <Text style={[styles.fontSizeButtonText, styles.fontSizeButtonTextActive]}>A</Text>
                </TouchableOpacity>
                <TouchableOpacity style={styles.fontSizeButton}>
                  <Text style={styles.fontSizeButtonText}>A+</Text>
                </TouchableOpacity>
              </View>
            </View>
          </View>
          
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Notifications</Text>
            
            <View style={styles.settingRow}>
              <View style={styles.settingInfo}>
                <Feather name="bell" size={22} color={theme.colors.primary} />
                <Text style={styles.settingText}>Push Notifications</Text>
              </View>
              <Switch
                value={notifications}
                onValueChange={setNotifications}
                trackColor={{ false: theme.colors.border, true: theme.colors.primary }}
                thumbColor={theme.colors.accent}
              />
            </View>
            
            <View style={styles.settingRow}>
              <View style={styles.settingInfo}>
                <Feather name="mail" size={22} color={theme.colors.primary} />
                <Text style={styles.settingText}>Email Notifications</Text>
              </View>
              <Switch
                value={false}
                trackColor={{ false: theme.colors.border, true: theme.colors.primary }}
                thumbColor={theme.colors.accent}
              />
            </View>
          </View>
          
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>About</Text>
            
            <TouchableOpacity style={styles.settingRow}>
              <View style={styles.settingInfo}>
                <Feather name="info" size={22} color={theme.colors.primary} />
                <Text style={styles.settingText}>About Poetica</Text>
              </View>
              <Feather name="chevron-right" size={22} color={theme.colors.lightText} />
            </TouchableOpacity>
            
            <TouchableOpacity style={styles.settingRow}>
              <View style={styles.settingInfo}>
                <Feather name="file-text" size={22} color={theme.colors.primary} />
                <Text style={styles.settingText}>Terms of Service</Text>
              </View>
              <Feather name="chevron-right" size={22} color={theme.colors.lightText} />
            </TouchableOpacity>
            
            <TouchableOpacity style={styles.settingRow}>
              <View style={styles.settingInfo}>
                <Feather name="lock" size={22} color={theme.colors.primary} />
                <Text style={styles.settingText}>Privacy Policy</Text>
              </View>
              <Feather name="chevron-right" size={22} color={theme.colors.lightText} />
            </TouchableOpacity>
          </View>
          
          <TouchableOpacity style={styles.logoutButton}>
            <Text style={styles.logoutText}>Log Out</Text>
          </TouchableOpacity>
          
          <Text style={styles.versionText}>Poetica v1.0.0</Text>
        </ScrollView>
      </ScreenContainer>
    </SafeAreaContainer>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingHorizontal: theme.spacing.md,
  },
  section: {
    marginBottom: theme.spacing.xl,
  },
  sectionTitle: {
    fontSize: theme.fontSizes.md,
    fontWeight: '600',
    color: theme.colors.primary,
    marginBottom: theme.spacing.md,
  },
  settingRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: theme.spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.border,
  },
  settingInfo: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  settingText: {
    fontSize: theme.fontSizes.md,
    color: theme.colors.text,
    marginLeft: theme.spacing.md,
  },
  fontSizeButtons: {
    flexDirection: 'row',
  },
  fontSizeButton: {
    width: 36,
    height: 36,
    borderRadius: 18,
    justifyContent: 'center',
    alignItems: 'center',
    marginLeft: theme.spacing.xs,
    borderWidth: 1,
    borderColor: theme.colors.border,
  },
  fontSizeButtonActive: {
    backgroundColor: theme.colors.primary,
    borderColor: theme.colors.primary,
  },
  fontSizeButtonText: {
    fontSize: theme.fontSizes.md,
    color: theme.colors.text,
  },
  fontSizeButtonTextActive: {
    color: theme.colors.accent,
  },
  logoutButton: {
    paddingVertical: theme.spacing.md,
    marginBottom: theme.spacing.xl,
    alignItems: 'center',
    borderRadius: theme.borderRadius.md,
    backgroundColor: 'rgba(220, 53, 69, 0.1)',
  },
  logoutText: {
    color: '#DC3545',
    fontSize: theme.fontSizes.md,
    fontWeight: '600',
  },
  versionText: {
    textAlign: 'center',
    color: theme.colors.lightText,
    fontSize: theme.fontSizes.sm,
    marginBottom: theme.spacing.xl,
  },
});

export default SettingsScreen;

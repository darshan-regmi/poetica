import React from 'react';
import { StyleSheet, Text, View, Image, TouchableOpacity, ScrollView } from 'react-native';
import { Feather, Ionicons } from '@expo/vector-icons';
import { theme } from '../styles/theme';
import { 
  SafeAreaContainer,
  ScreenContainer,
} from '../styles/styledComponents';

const ProfileScreen = () => {
  // Mock user data
  const user = {
    name: 'Darshan Regmi',
    username: '@darshanregmi',
    bio: 'Poetry enthusiast | Writer | Dreamer',
    followers: 245,
    following: 123,
    poems: 18,
  };
  
  // Mock poems data
  const poems = [
    {
      id: '1',
      title: 'Whispers of Dawn',
      preview: 'The morning light breaks through...',
      likes: 42,
      comments: 7,
      date: '3 days ago',
    },
    {
      id: '2',
      title: 'Silent Echoes',
      preview: 'In the quiet moments between...',
      likes: 38,
      comments: 5,
      date: '1 week ago',
    },
    {
      id: '3',
      title: 'Mountain Dreams',
      preview: 'Standing tall against the sky...',
      likes: 56,
      comments: 12,
      date: '2 weeks ago',
    },
  ];
  
  return (
    <SafeAreaContainer>
      <ScreenContainer>
        <ScrollView style={styles.container} showsVerticalScrollIndicator={false}>
          {/* Profile Header */}
          <View style={styles.profileHeader}>
            <Image 
              source={require('../../assets/image.png')} 
              style={styles.profileImage} 
            />
            
            <View style={styles.profileInfo}>
              <Text style={styles.name}>{user.name}</Text>
              <Text style={styles.username}>{user.username}</Text>
              <Text style={styles.bio}>{user.bio}</Text>
            </View>
            
            <TouchableOpacity style={styles.editButton}>
              <Text style={styles.editButtonText}>Edit Profile</Text>
            </TouchableOpacity>
          </View>
          
          {/* Stats */}
          <View style={styles.statsContainer}>
            <View style={styles.statItem}>
              <Text style={styles.statNumber}>{user.poems}</Text>
              <Text style={styles.statLabel}>Poems</Text>
            </View>
            <View style={styles.statDivider} />
            <View style={styles.statItem}>
              <Text style={styles.statNumber}>{user.followers}</Text>
              <Text style={styles.statLabel}>Followers</Text>
            </View>
            <View style={styles.statDivider} />
            <View style={styles.statItem}>
              <Text style={styles.statNumber}>{user.following}</Text>
              <Text style={styles.statLabel}>Following</Text>
            </View>
          </View>
          
          {/* Tabs */}
          <View style={styles.tabsContainer}>
            <TouchableOpacity style={[styles.tab, styles.activeTab]}>
              <Feather name="book-open" size={20} color={theme.colors.primary} />
              <Text style={styles.activeTabText}>My Poems</Text>
            </TouchableOpacity>
            <TouchableOpacity style={styles.tab}>
              <Feather name="heart" size={20} color={theme.colors.lightText} />
              <Text style={styles.tabText}>Favorites</Text>
            </TouchableOpacity>
            <TouchableOpacity style={styles.tab}>
              <Feather name="bookmark" size={20} color={theme.colors.lightText} />
              <Text style={styles.tabText}>Saved</Text>
            </TouchableOpacity>
          </View>
          
          {/* Poems List */}
          <View style={styles.poemsContainer}>
            {poems.map(poem => (
              <TouchableOpacity key={poem.id} style={styles.poemCard}>
                <View style={styles.poemHeader}>
                  <Text style={styles.poemTitle}>{poem.title}</Text>
                  <Text style={styles.poemDate}>{poem.date}</Text>
                </View>
                
                <Text style={styles.poemPreview}>{poem.preview}</Text>
                
                <View style={styles.poemFooter}>
                  <View style={styles.poemStat}>
                    <Ionicons name="heart-outline" size={18} color={theme.colors.lightText} />
                    <Text style={styles.poemStatText}>{poem.likes}</Text>
                  </View>
                  
                  <View style={styles.poemStat}>
                    <Ionicons name="chatbubble-outline" size={18} color={theme.colors.lightText} />
                    <Text style={styles.poemStatText}>{poem.comments}</Text>
                  </View>
                  
                  <TouchableOpacity style={styles.poemAction}>
                    <Feather name="more-horizontal" size={18} color={theme.colors.lightText} />
                  </TouchableOpacity>
                </View>
              </TouchableOpacity>
            ))}
          </View>
          
          {/* Create New Poem Button */}
          <TouchableOpacity style={styles.newPoemButton}>
            <Feather name="plus" size={24} color={theme.colors.accent} />
            <Text style={styles.newPoemText}>Create New Poem</Text>
          </TouchableOpacity>
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
  profileHeader: {
    alignItems: 'center',
    marginTop: theme.spacing.lg,
    marginBottom: theme.spacing.xl,
  },
  profileImage: {
    width: 100,
    height: 100,
    borderRadius: 50,
    borderWidth: 3,
    borderColor: theme.colors.primary,
  },
  profileInfo: {
    alignItems: 'center',
    marginTop: theme.spacing.md,
  },
  name: {
    fontSize: theme.fontSizes.xl,
    fontWeight: 'bold',
    color: theme.colors.text,
  },
  username: {
    fontSize: theme.fontSizes.md,
    color: theme.colors.lightText,
    marginTop: 2,
  },
  bio: {
    fontSize: theme.fontSizes.md,
    color: theme.colors.text,
    textAlign: 'center',
    marginTop: theme.spacing.sm,
  },
  editButton: {
    marginTop: theme.spacing.md,
    paddingVertical: theme.spacing.sm,
    paddingHorizontal: theme.spacing.lg,
    borderRadius: theme.borderRadius.md,
    borderWidth: 1,
    borderColor: theme.colors.primary,
  },
  editButtonText: {
    color: theme.colors.primary,
    fontSize: theme.fontSizes.sm,
    fontWeight: '600',
  },
  statsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-evenly',
    marginBottom: theme.spacing.xl,
    paddingVertical: theme.spacing.md,
    borderRadius: theme.borderRadius.md,
    backgroundColor: theme.colors.card,
  },
  statItem: {
    alignItems: 'center',
  },
  statNumber: {
    fontSize: theme.fontSizes.lg,
    fontWeight: 'bold',
    color: theme.colors.text,
  },
  statLabel: {
    fontSize: theme.fontSizes.sm,
    color: theme.colors.lightText,
    marginTop: 2,
  },
  statDivider: {
    width: 1,
    height: '70%',
    backgroundColor: theme.colors.border,
  },
  tabsContainer: {
    flexDirection: 'row',
    marginBottom: theme.spacing.lg,
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.border,
  },
  tab: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: theme.spacing.md,
  },
  activeTab: {
    borderBottomWidth: 2,
    borderBottomColor: theme.colors.primary,
  },
  tabText: {
    marginLeft: theme.spacing.xs,
    color: theme.colors.lightText,
    fontSize: theme.fontSizes.sm,
  },
  activeTabText: {
    marginLeft: theme.spacing.xs,
    color: theme.colors.primary,
    fontSize: theme.fontSizes.sm,
    fontWeight: '600',
  },
  poemsContainer: {
    marginBottom: theme.spacing.xl,
  },
  poemCard: {
    marginBottom: theme.spacing.lg,
    padding: theme.spacing.md,
    borderRadius: theme.borderRadius.md,
    backgroundColor: theme.colors.card,
  },
  poemHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: theme.spacing.sm,
  },
  poemTitle: {
    fontSize: theme.fontSizes.lg,
    fontWeight: '600',
    color: theme.colors.text,
  },
  poemDate: {
    fontSize: theme.fontSizes.xs,
    color: theme.colors.lightText,
  },
  poemPreview: {
    fontSize: theme.fontSizes.md,
    color: theme.colors.text,
    marginBottom: theme.spacing.md,
  },
  poemFooter: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  poemStat: {
    flexDirection: 'row',
    alignItems: 'center',
    marginRight: theme.spacing.md,
  },
  poemStatText: {
    marginLeft: 4,
    fontSize: theme.fontSizes.sm,
    color: theme.colors.lightText,
  },
  poemAction: {
    marginLeft: 'auto',
  },
  newPoemButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: theme.colors.primary,
    padding: theme.spacing.md,
    borderRadius: theme.borderRadius.md,
    marginBottom: theme.spacing.xl,
  },
  newPoemText: {
    color: theme.colors.accent,
    fontSize: theme.fontSizes.md,
    fontWeight: '600',
    marginLeft: theme.spacing.sm,
  },
});

export default ProfileScreen;

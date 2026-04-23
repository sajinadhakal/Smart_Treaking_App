import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { MaterialIcons } from '@expo/vector-icons';
import { TouchableOpacity } from 'react-native';
import useStore from './src/store/useStore';

// Screens
import HomeScreen from './src/screens/HomeScreen';
import TripListScreen from './src/screens/TripListScreen';
import TripDetailsScreen from './src/screens/TripDetailsScreen';
import AIPlannerScreen from './src/screens/AIPlannerScreen';
import EducationalPanelScreen from './src/screens/EducationalPanelScreen';
const Stack = createStackNavigator();
const Tab = createBottomTabNavigator();
// Home Stack
const HomeStack = () => {
  const { educationalMode, toggleEducationalMode } = useStore();
  return (
    <Stack.Navigator
      screenOptions={{
        headerStyle: {
          backgroundColor: '#2E7D32',
          elevation: 0,
          shadowOpacity: 0,
        },
        headerTintColor: '#fff',
        headerTitleStyle: {
          fontWeight: 'bold',
          fontSize: 20,
        },
      }}
    >
      <Stack.Screen 
        name="Home" 
        component={HomeScreen}
        options={{
          title: 'Nepal Trek Explorer',
          headerRight: () => (
            <TouchableOpacity 
              style={{ marginRight: 16 }}
              onPress={toggleEducationalMode}
            >
              <MaterialIcons 
                name={educationalMode ? "school" : "school-outlined"} 
                size={24} 
                color={educationalMode ? "#FFD700" : "#fff"} 
              />
            </TouchableOpacity>
          ),
        }}
      />
      <Stack.Screen 
        name="TripDetails" 
        component={TripDetailsScreen}
        options={{ headerShown: false }}
      />
    </Stack.Navigator>
  );
};
// Explore Stack
const ExploreStack = () => (
  <Stack.Navigator
    screenOptions={{
      headerStyle: {
        backgroundColor: '#2E7D32',
      },
      headerTintColor: '#fff',
      headerTitleStyle: {
        fontWeight: 'bold',
      },
    }}
  >
    <Stack.Screen 
      name="TripList" 
      component={TripListScreen}
      options={{ title: 'Explore Treks' }}
    />
    <Stack.Screen 
      name="TripDetails" 
      component={TripDetailsScreen}
      options={{ headerShown: false }}
    />
  </Stack.Navigator>
);
// AI Planner Stack
const PlannerStack = () => (
  <Stack.Navigator
    screenOptions={{
      headerStyle: {
        backgroundColor: '#2E7D32',
      },
      headerTintColor: '#fff',
      headerTitleStyle: {
        fontWeight: 'bold',
      },
    }}
  >
    <Stack.Screen 
      name="AIPlanner" 
      component={AIPlannerScreen}
      options={{ title: 'AI Trip Planner' }}
    />
    <Stack.Screen 
      name="TripDetails" 
      component={TripDetailsScreen}
      options={{ headerShown: false }}
    />
  </Stack.Navigator>
);
// Educational Stack
const EducationalStack = () => (
  <Stack.Navigator
    screenOptions={{
      headerStyle: {
        backgroundColor: '#2E7D32',
      },
      headerTintColor: '#fff',
      headerTitleStyle: {
        fontWeight: 'bold',
      },
    }}
  >
    <Stack.Screen 
      name="EducationalPanel" 
      component={EducationalPanelScreen}
      options={{ title: 'Algorithms' }}
    />
  </Stack.Navigator>
);
// Main Tab Navigator
const MainTabs = () => {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        tabBarIcon: ({ focused, color, size }) => {
          let iconName;

          if (route.name === 'HomeTab') {
            iconName = 'home';
          } else if (route.name === 'ExploreTab') {
            iconName = 'explore';
          } else if (route.name === 'PlannerTab') {
            iconName = 'auto-awesome';
          } else if (route.name === 'EducationalTab') {
            iconName = 'school';
          }
          return <MaterialIcons name={iconName} size={size} color={color} />;
        },
        tabBarActiveTintColor: '#2E7D32',
        tabBarInactiveTintColor: '#666',
        headerShown: false,
        tabBarStyle: {
          height: 60,
          paddingBottom: 8,
          paddingTop: 8,
          elevation: 8,
          shadowColor: '#000',
          shadowOffset: { width: 0, height: -2 },
          shadowOpacity: 0.1,
          shadowRadius: 8,
        },
        tabBarLabelStyle: {
          fontSize: 12,
          fontWeight: '600',
        },
      })}
    >
      <Tab.Screen 
        name="HomeTab" 
        component={HomeStack}
        options={{ tabBarLabel: 'Home' }}
      />
      <Tab.Screen 
        name="ExploreTab" 
        component={ExploreStack}
        options={{ tabBarLabel: 'Explore' }}
      />
      <Tab.Screen 
        name="PlannerTab" 
        component={PlannerStack}
        options={{ tabBarLabel: 'AI Planner' }}
      />
      <Tab.Screen 
        name="EducationalTab" 
        component={EducationalStack}
        options={{ tabBarLabel: 'Learn' }}
      />
    </Tab.Navigator>
  );
};
export default function App() {
  return (
    <NavigationContainer>
      <MainTabs />
    </NavigationContainer>
  );
}

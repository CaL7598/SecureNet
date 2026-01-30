/**
 * Main Navigation Setup
 */
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { createStackNavigator } from '@react-navigation/stack';
import { colors } from '../theme/colors';
import Icon from '../utils/iconHelper';

// Screens
import ScanScreen from '../screens/ScanScreen';
import ResultsScreen from '../screens/ResultsScreen';
import DeviceDetailScreen from '../screens/DeviceDetailScreen';
import SettingsScreen from '../screens/SettingsScreen';
import HistoryScreen from '../screens/HistoryScreen';
import MapScreen from '../screens/MapScreen';

const Tab = createBottomTabNavigator();
const Stack = createStackNavigator();

function ScanStack() {
  return (
    <Stack.Navigator
      screenOptions={{
        headerStyle: { backgroundColor: colors.background },
        headerTintColor: colors.text,
        headerTitleStyle: { color: colors.text },
      }}
    >
      <Stack.Screen 
        name="ScanMain" 
        component={ScanScreen}
        options={{ headerShown: false }}
      />
      <Stack.Screen 
        name="Results" 
        component={ResultsScreen}
        options={{ 
          title: 'Scan Results',
          headerBackTitleVisible: false,
          headerShown: true,
        }}
      />
      <Stack.Screen 
        name="DeviceDetail" 
        component={DeviceDetailScreen}
        options={{ 
          title: 'Device Details',
          headerBackTitleVisible: false,
        }}
      />
    </Stack.Navigator>
  );
}

function AppNavigator() {
  return (
    <NavigationContainer>
      <Tab.Navigator
        screenOptions={{
          tabBarActiveTintColor: colors.tabActive,
          tabBarInactiveTintColor: colors.tabInactive,
          tabBarStyle: {
            backgroundColor: colors.surface,
            borderTopColor: colors.border,
          },
          headerShown: false,
        }}
      >
        <Tab.Screen
          name="Scan"
          component={ScanStack}
          options={{
            tabBarIcon: ({ color, size }) => (
              <Icon name="scan-helper" size={size} color={color} />
            ),
          }}
        />
        <Tab.Screen
          name="Map"
          component={MapScreen}
          options={{
            tabBarIcon: ({ color, size }) => (
              <Icon name="map" size={size} color={color} />
            ),
          }}
        />
        <Tab.Screen
          name="History"
          component={HistoryScreen}
          options={{
            tabBarIcon: ({ color, size }) => (
              <Icon name="history" size={size} color={color} />
            ),
          }}
        />
        <Tab.Screen
          name="Settings"
          component={SettingsScreen}
          options={{
            tabBarIcon: ({ color, size }) => (
              <Icon name="cog" size={size} color={color} />
            ),
          }}
        />
      </Tab.Navigator>
    </NavigationContainer>
  );
}

export default AppNavigator;

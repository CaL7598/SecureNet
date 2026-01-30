/**
 * Icon Helper - Web Compatible Icon Loading
 */
import { Platform, View, StyleSheet } from 'react-native';
import React from 'react';

let IconComponent: any;

if (Platform.OS === 'web') {
  // Web - use react-icons with proper React Native Web wrapper
  const ReactIcons = require('react-icons/md');
  
  const iconMap: { [key: string]: any } = {
    'scan-helper': ReactIcons.MdQrCodeScanner,
    'map': ReactIcons.MdMap,
    'history': ReactIcons.MdHistory,
    'cog': ReactIcons.MdSettings,
    'shield-check': ReactIcons.MdShield,
    'check-circle': ReactIcons.MdCheckCircle,
    'laptop': ReactIcons.MdLaptop,
    'devices': ReactIcons.MdDevices,
    'clock-outline': ReactIcons.MdAccessTime,
    'bell': ReactIcons.MdNotifications,
    'alert-circle': ReactIcons.MdWarning,
    'alert': ReactIcons.MdWarning,
    'help-circle': ReactIcons.MdHelpOutline,
    'chevron-right': ReactIcons.MdChevronRight,
    'lightbulb-on': ReactIcons.MdLightbulb,
  };

  IconComponent = ({ name, size = 24, color = '#000', style }: any) => {
    const Icon = iconMap[name] || ReactIcons.MdHelpOutline;
    
    // Wrap in View to avoid style conflicts with React Native Web
    return (
      <View style={[webStyles.container, { width: size, height: size }, style]}>
        {React.createElement(Icon, {
          size: size,
          color: color,
          // Don't pass style prop to avoid CSS conflicts
        })}
      </View>
    );
  };
} else {
  // Native - use react-native-vector-icons
  IconComponent = require('react-native-vector-icons/MaterialCommunityIcons').default;
}

const webStyles = StyleSheet.create({
  container: {
    justifyContent: 'center',
    alignItems: 'center',
    overflow: 'visible',
  },
});

export default IconComponent;

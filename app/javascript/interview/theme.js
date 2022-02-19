const ThemeConfigs = {
    'blues-rock': {
        highlight: 'tomorrow-night-blue'
    },
    "pop": {
        highlight: 'github'
    }
}

export default function Theme(themeName) {
    this.name = themeName;
    this.config = ThemeConfigs[themeName];
}

Theme.instanceOf = function(themeName) {
    if (ThemeConfigs[themeName]) {
        return new Theme(themeName);
    }
}

// TODO: support theme setting
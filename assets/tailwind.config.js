function genColorGrade(name) {
  const grades = [
    'default', 
    'faint', 
    'fainter',
    'faintest',
    'strong',
    'stronger',
    'strongest'
  ]
  return Array.from(
    new Array(7), 
    (x, i) => [grades[i], `var(--color-${name}-${grades[i]})`]
  ).reduce((acc, [key, value]) => {
    acc[key] = value
    
    return acc
  }, {})
}

module.exports = {
  purge: [],
  theme: {
    extend: {
      colors: {
        'background': genColorGrade('background'),
        'foreground': genColorGrade('foreground'),
        'primary': genColorGrade('primary'),
        'secondary': genColorGrade('secondary'),
        'legible': genColorGrade('legible'),
        'warning': genColorGrade('warning')
      }
    },
  },
  variants: {},
  plugins: [
    require('@tailwindcss/typography')
  ],
}

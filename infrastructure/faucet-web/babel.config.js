module.exports = {
  presets: ['@vue/cli-plugin-babel/preset'],
  plugins: [
    /* @PC.element-ui */
    /* element-ui ：https://github.com/ElementUI/babel-plugin-component */
    [
      'component',
      {
        libraryName: 'element-ui',
        styleLibraryName: 'theme-chalk', //  style: false
      },
      'element-ui',
    ],

    /* @H5.vant */
    /* vant ：https://github.com/ElementUI/babel-plugin-component */
    [
      'component',
      {
        libraryName: 'vant',
        style: 'style/less.js',
      },
      'vant',
    ],

    /* lodash ：https://github.com/lodash/babel-plugin-lodash */
    ['lodash'],
  ],
}



<script>
let requireCtx
try {
  requireCtx = require.context(
    './icons/',
    false, 
    /\.svg$/,
  )
} catch (err) {
  if (
    err.code === 'MODULE_NOT_FOUND'
  ) {
    requireCtx = () => {}
    requireCtx.keys = () => []
  } else {
    throw err
  }
}

const fileNames = requireCtx.keys()
const names = Object.freeze(
  fileNames.map(fileName =>
    fileName
      .split(/[/\\]+/)
      .pop()
      .replace(/\.\w+$/, ''),
  ),
)
fileNames.forEach(fileName => requireCtx(fileName))

export { names }
export default {
  name: 'SvgIcon',
  props: {
    icon: {
      type: String,
      required: true,
    },
  },
}
</script>

<template>
  <i :class="['svg-icon', `svg-icon-${icon}`]">
    <svg class="svg-icon__icon">
      <use :xlink:href="`#svgSpriteIcon__${icon}`" />
    </svg>
  </i>
</template>

<style lang="less">
.svg-icon {
  display: inline-block;
  width: 1em;
  height: 1em;
  vertical-align: -0.165em;
  font-style: normal;
  line-height: 1;
  &__icon {
    display: block;
    overflow: hidden;
    width: 100%;
    height: 100%;
    fill: currentColor;
  }
}

[id^='svgSpriteIcon__']:not([id^='svgSpriteIcon__mt-']) {
  [fill]:not([fill='none']):not([fill='transparent']) {
    fill: currentColor;
  }
  [stroke]:not([stroke='none']):not([stroke='transparent']) {
    stroke: currentColor;
  }
}
</style>

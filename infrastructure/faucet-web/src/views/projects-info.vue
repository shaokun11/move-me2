<!-- @author middear -->

<script>
export default {
  name: 'ProInfo',
  props: {
    msg: {
      type: String,
      default: '',
    },
  },
}
</script>

<template>
  <div :class="$style.box">
    Projects info
  </div>
</template>

<style lang="less" module>
.box {
  
}
</style>

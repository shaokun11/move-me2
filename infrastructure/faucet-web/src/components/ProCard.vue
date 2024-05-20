<!-- @author middear -->

<script>
export default {
  name: 'ProCard',
  props: {
    pro: {
      type: Object,
      default: {},
    },
    totalRaised:{type:Number,default:100},
    price:{type:Number,default:1},
    participants:{type:Number,default:1},
    startTime:{type:String,default:"2023-10-31"},
  },
}
</script>

<template>
    <div :class="$style.card1" >
        <div :class="$style.card1_img_con">
            <img :class="$style.card1_img" :src="require('../assets/nft'+(pro.index+1)+'.png')" />
        </div>
        
        <div :class="$style.card1_con">
            <div :class="$style.card1_t1">Total Raised</div>
            <div :class="$style.card1_t2">${{ totalRaised }}</div>
            <div>
                <div :class="$style.card1_ts">
                    <span :class="$style.card1_t3">Price</span>
                    <span :class="$style.card1_t4">{{price}}</span>
                </div>
                <div :class="$style.card1_ts">
                    <span :class="$style.card1_t3">Participants</span>
                    <span :class="$style.card1_t4">{{participants}}</span>
                </div>
                <div :class="$style.card1_ts">
                    <span :class="$style.card1_t3">Start Time</span>
                    <span :class="$style.card1_t4">{{startTime}}</span>
                </div>
            </div>
        </div>
    </div>

</template>


<style lang="less" module>
.card1{
  position: relative;
  width: 370px;
  border-radius: 30px;
  background: #FFF;
  overflow: hidden;
  cursor: pointer;
}
.card1:hover{
    .card1_img{
        transform: scale(1.2);
    }
}
.card1_con{
    padding: 32px 26px 50px;
}
.card1_img_con{
  width: 100%;
  height: 190px;
  overflow: hidden;
}
.card1_ts{
    margin-top: 24px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}
.card1_img{
  width:100%;
  transition: all .5s ease .1s;
}



.card1_t1{
    color: #000;
    font-family: Trans Sans Premium;
    font-size: 22px;
    font-weight: 700;
}
.card1_t2{
    color: #FF684B;
    font-family: Trans Sans Premium;
    font-size: 30px;
    font-weight: 700;
}
.card1_t3{
    color: #000;
    font-family: Trans Sans Premium;
    font-size: 22px;
    font-weight: 500;
}
.card1_t4{
    color: #000;
    font-family: Trans Sans Premium;
    font-size: 22px;
    font-weight: 700;
}

</style>

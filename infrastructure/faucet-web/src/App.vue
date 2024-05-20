<script>
import {mapGetters,mapMutations} from "vuex";
import HeadG from '@/components/head.vue'
import Footer from '@/components/Foot.vue'
import {connect,changeMetamaskChain} from './scripts/utils/sdk'
export default {
  components: { HeadG, Footer },
  data() {
    return {

      ID:336,

      wallets:[
        {
          id:"injected",
          icon:'metamask',
          name:"Metamask",
        },
        // {
        //   id:"walletconnect",
        //   icon:'walletConnect',
        //   name:"Wallet Connect",
        // },
        {
          id:"coinbase",
          icon:'coinbaseWallet',
          name:"Coinbase Wallet",
        },
        {
          id:"binance",
          icon:'binanceChainWallet',
          name:"Binance Chain Wallet",
        },
      ],
      selW:null,

      otherNetwork:{
        chainId:1,
        icon:"",
        name:"",
      },
    }
      
  },
  created() {
    
  },
  mounted(){
  },
  methods:{
    ...mapMutations('user',['setAccount','setshowConnect','setshowSwitchNet','setIcon','setNetwork']),
    showToast:function(content,type='success'){
      this.$message({
          message: content,
          type: type||'success',
          duration:3500
        });
    },
    selWallet:function(value){
      this.selW = value;
      console.log('selWallet=',value);
      connect(value,(res)=>{
        console.log('account-info=',res,res.providerInfo.logo)
        if(res.chainID==this.ID){
          this.setIcon(res.providerInfo.logo);
          this.setAccount(res.account);
          this.setNetwork(res.chain);
          this.setshowConnect(false);
          this.setshowSwitchNet(false);
          
          if(res.message=="accountsChanged"){
            this.showToast('The account is successfully changed.');
          }else{
            this.showToast('The wallet is successfully connected.');
          }
          

        }else{
          if(res.chainID){
            this.setAccount("");
            this.setNetwork("");
            this.setshowConnect(false);
            this.setshowSwitchNet(true);

            this.otherNetwork={
              chainId:res.chainID,
              icon:res.providerInfo.logo,
              name:res.chain,
            };
          }

        }
      })
    },

    switchNet:async function(){
      changeMetamaskChain(this.ID);
    }, 
    handleClose1:function(){this.setshowConnect(false)},
    handleClose2:function(){this.setshowSwitchNet(false)},
    

  },
 
  computed: {
    ...mapGetters(["showConnect","showSwitchNet","account",'network','icon']),
    }
}
</script>

<template>
  <div :class="$style.con1">
    <HeadG></HeadG>

  
    
    <router-view />

    <el-dialog title="Connect Wallet" :visible.sync="showConnect" :before-close="handleClose1" >
      <div :class="$style.witem" v-for="(item,index) in wallets" :style="selW==item.name?'background: #ffd016;':''" :key="index" @click="selWallet(item.id)">
        <img :class="$style.witemimg" :src="require('./assets/'+item.icon+'.png')" />
        <span :class="$style.witemtxt" :style="selW==item.name?'color: #FFF;':''">{{ item.name }}</span>
      </div>
    </el-dialog>

    <el-dialog title="Switch Network" :visible.sync="showSwitchNet" :before-close="handleClose2" width="480px">
      <div :class="$style.switchCon">
        <div :class="$style.switchConP1" style="text-align: center;">
            You're currently on {{otherNetwork.name}}.
          <br>
          Please switch to <span style="color:#ffd016;">EVM-MOVE. </span>
        </div>
        <div style="margin-top: 12px;display: flex;align-items: center;justify-content: center;">
          <img style="width: 68px;" :src="otherNetwork.icon" />
          <img style="width: 48px; margin: 0 24px;" src="./assets/arrow_right.png" />
          <img style="width: 68px;" src="./assets/defaultNetwork.png" />
        </div>

        <div style="margin-top:32px;text-align: center;">
          <el-button type="primary" :class="$style.card1_btn" @click="switchNet">Switch</el-button>
        </div>
      </div>
    </el-dialog>

    <!-- <Footer></Footer> -->
  </div>
</template>

<style lang="less" module>
.con1{
  width: 100%;
  min-height: 100vh;
  background: #1E1E1E;
  overflow-y: auto;
  
}
// .con2{
//   width: 100%;
//   min-height: 100vh;
//   background-image: url(./assets/bg.jpg);
//   background-size: 100% 100%;
//   background-repeat: no-repeat;
// }

.witem{
  position: relative;
  cursor: pointer;
  padding: 12px 28px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  margin-bottom: 24px;

  display: flex;
  align-items: center;
  border: transparent solid 1px;
  
}
.witem:hover{
  border: #ffd016 solid 1px;
}
.witem:hover span{
  color: #ffd016;
  font-size: 15px;
}
.witemimg{
  width: 36px;
  margin-right: 10px;
}
.witemtxt{
  font-family: 'IBM Plex Mono';
  font-style: normal;
  font-weight: 700;
  font-size: 14px;
  line-height: 20px;

  color: white;

}


.switchCon{
  position: relative;
}
.switchConP1{
  font-family: 'IBM Plex Mono';
  font-style: normal;
  font-weight: 700;
  font-size: 16px;
  line-height: 24px;

  color: #FFFFFF;
}



</style>

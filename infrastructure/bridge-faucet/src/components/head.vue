<!-- @author middear -->

<script>
import {mapGetters,mapMutations} from 'vuex'
import {logout} from '../scripts/utils/sdk'
import copy from 'copy-to-clipboard';
import {petraConnect,petraGetbalance} from '../scripts/utils/petra'
import { trace } from '@/scripts/utils/tools';
 
// const router=useRouter()
export default {
  name: 'headG',
  data(){
    
    return {
        activeIndex:'/',

    }
  },
  watch:{
    '$route'(a,b){
      console.log(a,b)
      this.activeIndex = a.path;
    }
  },
  created(){
  },
  mounted(){
    console.log("router=",this.$route)
  },
  methods:{
    ...mapMutations('user',['setAccount','setAptAccount','setshowConnect','setshowSwitchNet','setNetwork']),
    handleSelect(key, keyPath) {
        // console.log(key, keyPath);
      },
    loginOut:function(){
      let res = logout();
      this.setAccount("");
      this.setNetwork("");
    },
    loginOutApt:function(){
      let res = logout();
      this.setAptAccount(null);
    },
    showToast:function(content,type='success'){
      this.$message({
          message: content,
          type: type||'success',
          duration:3500
        });
    },
    copyToAcc:function(){
      if(copy(this.account, {
        debug: true,
        message: 'Address replication succeeded',
      })){
        this.showToast('Address replication succeeded.');
      };
    },
    copyToAccApt:function(){
      if(copy(this.aptAccount.address, {
        debug: true,
        message: 'Address replication succeeded',
      })){
        this.showToast('Address replication succeeded.');
      };
    },
    connecWallet: function(){
      this.setshowConnect(true);
    },
    async connecAPT(){
      try{
        let acc = await petraConnect((res)=>{
          if(res.code!=4001){
            this.setAptAccount(res)
          }
        });
        trace('acc=',acc)
        if(acc){
          this.setAptAccount(acc)
        }
      }catch(e){
        trace(e)
      }
    },
    
    
  },

  computed: {
      ...mapGetters(["showConnect","showSwitchNet","aptAccount","account",'icon','network']),
    }
  
}
</script>

<template>
  <div :class="$style.heard">
      <div style="display: flex;align-items: center;">
        <img style="height:20px" src="../assets/logo_txt_w.svg" />
      </div>
     
      <div >
        <el-menu :default-active="activeIndex" :class="$style.nav0" 
          mode="horizontal"
          background-color="transparent"
          text-color="#FFF"
          active-text-color="#FFD016"
          router
          @select="handleSelect">
          <el-menu-item index="/" >Bridge</el-menu-item>
          <el-menu-item index="/Faucet">Faucet</el-menu-item>
        </el-menu>
      </div>

      <span v-if="activeIndex=='/'" style="display: inline-flex;">

      
        <el-button type="primary" plain  v-if="!aptAccount" :class="$style.btn1" @click="connecAPT">Connect Petra</el-button>
        <div v-else>
          <el-popover
            placement="bottom-end"
            width="162"
            trigger="click"
            >
            <div :class="$style.accoutInfo">
              <div>
                <div :class="$style.accoutInfoTitle">Network：</div>
                <div>
                  <span style="display: inline-block;border-radius: 4px;width: 4px;height: 4px;background: #1EECBB;margin-right: 8px;margin-bottom: 3px;"></span>
                  MOVE-APT</div>
              </div>
              <div style="border: 1px solid rgba(255, 255, 255, 0.03);width:200px;margin-left: -20px;margin-top: 6px;"></div>
              <div style="margin-top: 16px; display: flex;cursor: pointer;" @click="copyToAccApt">
                <img src="../assets/icon_copy.png" />
                Copy Address
              </div>
              <div style="margin-top: 16px; display: flex;cursor: pointer;" @click="loginOutApt">
                <img src="../assets/icon_balance.png" />
                Disconnect
              </div>
            </div>
            <div :class="$style.mcon2" slot="reference" >
              <span style="width:18px;height:17px;margin-right: 6px;color: white;">
                <svg width="100%" height="100%" baseProfile="tiny" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 112 112" overflow="visible" xml:space="preserve"><path fill="currentColor" d="M86.6 37.4h-9.9c-1.1 0-2.2-.5-3-1.3l-4-4.5c-1.2-1.3-3.1-1.4-4.5-.3l-.3.3-3.4 3.9c-1.1 1.3-2.8 2-4.5 2H2.9C1.4 41.9.4 46.6 0 51.3h51.2c.9 0 1.8-.4 2.4-1l4.8-5c.6-.6 1.4-1 2.3-1h.2c.9 0 1.8.4 2.4 1.1l4 4.5c.8.9 1.9 1.4 3 1.4H112c-.4-4.7-1.4-9.4-2.9-13.8H86.6zM53.8 65l-4-4.5c-1.2-1.3-3.1-1.4-4.5-.3l-.3.3-3.5 3.9c-1.1 1.3-2.7 2-4.4 2H.8c.9 4.8 2.5 9.5 4.6 14h25.5c.9 0 1.7-.4 2.4-1l4.8-5c.6-.6 1.4-1 2.3-1h.2c.9 0 1.8.4 2.4 1.1l4 4.5c.8.9 1.9 1.4 3 1.4h56.6c2.1-4.4 3.7-9.1 4.6-14H56.8c-1.2 0-2.3-.5-3-1.4zm19.6-43.6 4.8-5c.6-.6 1.4-1 2.3-1h.2c.9 0 1.8.4 2.4 1l4 4.5c.8.9 1.9 1.3 3 1.3h10.8c-18.8-24.8-54.1-29.7-79-11-4.1 3.1-7.8 6.8-11 11H71c1 .2 1.8-.2 2.4-.8zM34.7 94.2c-1.2 0-2.3-.5-3-1.3l-4-4.5c-1.2-1.3-3.2-1.4-4.5-.2l-.2.2-3.5 3.9c-1.1 1.3-2.7 2-4.4 2h-.2C36 116.9 71.7 118 94.4 96.7c.9-.8 1.7-1.7 2.6-2.6H34.7z"></path></svg>
              </span>
              <span :class="$style.mcont1">{{ aptAccount.address.slice(0,4)+"..."+aptAccount.address.slice(-4) }}</span>
            </div>
          </el-popover>
        </div>

        <span style="width: 24px;"></span>
        
        <el-button type="primary"  v-if="!account||account.length<10" :class="$style.btn1" @click="connecWallet">Connect EVM</el-button>
        <div v-else>
          <el-popover
            placement="bottom-end"
            width="162"
            trigger="click"
            >
            <div :class="$style.accoutInfo">
              <div>
                <div :class="$style.accoutInfoTitle">Network：</div>
                <div>
                  <span style="display: inline-block;border-radius: 4px;width: 4px;height: 4px;background: #1EECBB;margin-right: 8px;margin-bottom: 3px;"></span>
                  {{ network }}</div>
              </div>
              <div style="border: 1px solid rgba(255, 255, 255, 0.03);width:200px;margin-left: -20px;margin-top: 6px;"></div>
              <div style="margin-top: 16px; display: flex;cursor: pointer;" @click="copyToAcc">
                <img src="../assets/icon_copy.png" />
                Copy Address
              </div>
              <div style="margin-top: 16px; display: flex;cursor: pointer;" @click="loginOut">
                <img src="../assets/icon_balance.png" />
                Disconnect
              </div>
            </div>
            <div :class="$style.mcon" slot="reference" >
              <img style="width:18px;height:17px;margin-right: 6px;" :src="icon" />
              <span :class="$style.mcont1">{{ account.slice(0,4)+"..."+account.slice(-4) }}</span>
            </div>
          </el-popover>
        </div>

      </span>
      <span v-else style="width: 320px;"></span>
      
    </div>
</template>

<style lang="less" module>
.heard {
  position: relative;
  height: 40px;
  padding: 20px 56px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.btn1{
  width: 148px;
}

.nav0{
  border: 0 !important;
 
  // border-bottom: solid 0.0625rem transparent !important;
}

.mcon{
  padding: 12px 16px;
  cursor: pointer;

  display: inline-flex;
  align-items: center;

  margin-left: 16px;

  border-radius: 12px;
  border: 1px solid #ffd016;
  background: #ffd016;
}
.mcon2{
  padding: 12px 16px;
  cursor: pointer;

  display: inline-flex;
  align-items: center;

  margin-left: 16px;

  border-radius: 12px;
  border: 1px solid #ffd016;
}
.mcon:hover{
  border: 1px solid #3e0347;
}
.mcont1{
  color: #FFF;
  font-feature-settings: 'salt' on, 'liga' off;
  font-family: Sora;
  font-size: 12px;
  font-weight: 400;

}

.accoutInfo{
  // background: rgba(0, 0, 0, 0.2);
  // border-radius: 12px 12px 0px 0px;
  // transform: matrix(1, 0, 0, -1, 0, 0);
  // padding: 20px;

  font-family: 'IBM Plex Mono';
  font-style: normal;
  font-weight: 600;
  font-size: 14px;
  line-height: 24px;
  /* identical to box height, or 171% */


  color: #FFF;
}
.accoutInfoTitle{
  font-family: 'GT America Trial';
  font-style: normal;
  font-weight: 400;
  font-size: 12px;
  line-height: 20px;

  color: #fff;

}
.accoutInfo img{
  width:24px;
  margin-right: 8px;
}
</style>

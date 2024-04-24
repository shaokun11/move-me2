<!-- description -->
<!-- @author midder -->

<script>
import style from './style.module.less'
import {mapGetters} from 'vuex'
import GroupCard from '../../components/GroupCard.vue'
import {petraGetbalance,petraSend,getMov} from '../../scripts/utils/petra'
import {hkGetTime,toFixed4,trace,replaceStr} from '../../scripts/utils/tools'
import {getBalance,withdraw} from '../../scripts/utils/sdk'


// import { Web3ModalAuth } from "@web3modal/auth-html"
const env = process.env;

export default {
  name: 'Home',
  components: { GroupCard },
  data() {
    return {
      style,
      isLoading:false,
      isGeLoading:false,
      gas:0.02,
      toFixed4:toFixed4,
      Env:env,
      success:{
        isShow:false,
        from:'optos',//  optos/evm
        content:'10,000 MVMT successfully Bridge to 0x3c5...7AA0',
        content2:'From MOVEMENT Testnet to MOVE-EVM',
        hash:'',
      },

      chain1:{
        id:1,
        isLogin:false,
        name:'MOVEMENT Testnet',
        symbol:'MVMT',
        decimals:18,
        balance:0,
        price:1,
      },
      chain2:{
        id:2,
        isLogin:false,
        name:'MOVE-EVM',
        symbol:'MVMT-EVM',
        decimals:18,
        balance:0,
        price:1,
      },
      upChain:null,
      downChain:null,
      
      num:0.00,
      toAddress:'',
    
      
    }
  },
  watch:{
    account(val){
      this.checkInfo();
    },
    network(val){
      this.checkInfo();
    },
    aptAccount(val){
      trace('aptAccount=',val)
      if(val){
        this.chain1.isLogin = true;
        this.upAptBalance();
      }else{
        this.chain1.balance = 0;
        this.chain1.isLogin = false;
      }
    }
  },
  created() {
    this.upChain = this.chain1;
    this.downChain = this.chain2;
    
   
    this.checkInfo();
    setInterval(() => {
      this.checkInfo();
    }, 3500);
  },
  mounted(){
    console.log("Env=",this.Env);
  },
  methods:{

    async checkInfo(){
      if(this.account&&this.network){
        this.chain2.isLogin = true;
      }else{
        this.chain2.isLogin = false;
      }

      this.upBalance();
      this.upAptBalance();
    },

    showMsg(title,content){
      this.$alert(content, title, {
          confirmButtonText: 'Confirm',
          callback: action => {
            // this.$message({
            //   type: 'info',
            //   message: `action: ${ action }`
            // });
          }
        }
      );
      // this.$message({
      //         type: 'info',
      //         message: `action: ${ 'aaa' }`
      //       });
    },
    handleClick(){
    },
    
    
    showToast:function(content,type='success'){
      this.$message({
          message: content,
          type: type||'success',
          duration:4500
        });
    },
    
    showInputModel:function(run){
      this.$prompt('', 'Set', {
          confirmButtonText: 'Confirm',
          showCancelButton:false,
          // cancelButtonText: 'cancel',
          // inputPattern: /[\w!#$%&'*+/=?^_`{|}~-]+(?:\.[\w!#$%&'*+/=?^_`{|}~-]+)*@(?:[\w](?:[\w-]*[\w])?\.)+[\w](?:[\w-]*[\w])?/,
          inputErrorMessage: 'Please enter the content'
        }).then(({ value }) => {
          if(run)run(value);
        }).catch((e) => {
          if(run) run(e)
        });
    },

    
    async toBridge(){
      this.isLoading = true;
      trace('toBridge-id',this.upChain.id)
      if(this.upChain.id==1){
        petraSend(this.num,this.toAddress,(code,hash)=>{
          this.isLoading = false;
          trace(code,hash);
          if(code==1){
            this.showToast('Bridge Send success')
            this.showSuccessDev(hash)

          }else{
            this.showToast(hash,'error')
          }
        })
      }else{

        withdraw(this.toAddress,this.num,this.account,(code,hash)=>{
          this.isLoading = false;
          trace('toBridge-res',code,hash);
          if(code==1){
            this.showToast('Bridge Send success')
            this.showSuccessDev(hash)
          }else if(code==0){
            this.showToast('Bridge Send ...')
          }else{
            this.showToast(hash,'error')
          }
        });
        

      }

    },
    toMax(){
      this.num = Math.max(this.upChain.balance-this.gas,0);
      // if(this.upChain.id==1){
      //   this.num = Math.max(this.upChain.balance-0.0001,0);
      // }else{
      //   this.num = this.upChain.balance;
      // }
    },
    async upAptBalance(){
      if(this.chain1.isLogin){
        let res = await petraGetbalance('APT',this.aptAccount.address);
        this.chain1.balance = res;
        // trace('upAptBalance-',res)
      }
    },
    async upBalance(){
      if(this.chain2.isLogin){
        this.chain2.balance = await getBalance(this.account);
        // trace('upBalance-',this.chain1.balance)
      }
      // let res = await petraGetbalance('APT',this.aptAccount.address);
      // this.chain1.balance = res;
      // trace(res)
    },
    async getMove(){
      this.isGeLoading = true;
      let res = await getMov(this.aptAccount.publicKey);
      this.isGeLoading = false;
      if(res&&res.length==1&&res[0].length==66){
        this.showToast('Get success.')
      }
      trace('getMove-res',res);
    },
    switchNet(){
      if(this.upChain.id==1){
        this.upChain = this.chain2;
        this.downChain = this.chain1;

        this.success.from=='evm';
      }else{
        this.upChain = this.chain1;
        this.downChain = this.chain2;
        this.success.from=='optos';
      }
      this.num=0;
      trace('switchNet-id = ',this.upChain.id)

    },

    isdisBridge(){
      if(this.upChain.id==1&&this.toAddress.length!=42){
        return true;
      }else if(this.upChain.id==2&&this.toAddress.length!=66){
        return true;
      }
      return !this.upChain.isLogin||this.num<=0||!this.toAddress||this.num>this.upChain.balance-this.gas;

    },
    jump(){
      if(this.success.isShow){
        window.open(Env.VUE_APP_EXPLORER+'/#/txn/'+this.success.hash+'?network=local');
       
      }
    },
    showSuccessDev(hash){
      this.success.hash = hash;
      this.success.content = this.num+' '+this.upChain.symbol+' successfully Bridge to '+replaceStr(this.toAddress);
      this.success.content2 = 'From '+this.upChain.name+' to '+this.downChain.symbol;
      this.success.isShow = true;

    },
    
  },
  computed: {
    ...mapGetters(["showConnect","showSwitchNet","account",'aptAccount','network']),
      
    }
}
</script>

<template>
  <div class="container">

    <div class="p1">
      <div class="card0">
        <span>
          <div style="font-weight: bold;">Petra wallet config:</div>
          <div>
            <span class="p1-t1">Rpc Url:</span>
            <span class="p1-t2" >{{Env.VUE_APP_MOVE_RPC}}</span>
          </div>
          <div>
            <span class="p1-t1">Symbol:</span>
            <span class="p1-t3">{{Env.VUE_APP_MOVE_SYMBOL||"MOV-Move"}}</span>
          </div>
        </span>
        <span>
          <div >EVM wallet config:</div>
          <div>
            <span class="p1-t1">Rpc Url:</span>
            <span class="p1-t2" >{{Env.VUE_APP_EVM_RPC}}</span>
          </div>
          <div>
            <span class="p1-t1">Chain ID:</span>
            <span >{{Env.VUE_APP_EVM_CHAINID||"336"}}</span>
          </div>
          <div>
            <span class="p1-t1">Symbol:</span>
            <span class="p1-t3">{{Env.VUE_APP_EVM_SYMBOL||"MOV EVM"}}</span>
          </div>
        </span>
      </div>

      <div class="card1">
        <div class="card-header">
          <span class="card1-t1">
            From:
            <span style="color: #161616;font-size: 16px;font-weight: 700;">{{upChain.name}}</span>
          </span>
          <span class="card1-t1" style="margin-top: 10px;">
            Balance:
            <span style="color: #161616;font-size: 16px;font-weight: 700;">
              {{toFixed4(upChain.balance)}} {{upChain.symbol}}
            </span>
            
            <!-- <el-button v-if="upChain&&upChain.id==1&&upChain.isLogin&&upChain.balance<1" style="border-color: #161616;border-radius: 12px;" plain size="mini" @click="getMove" :loading="isGeLoading">GET</el-button> -->
          </span>
        </div>
        <div class="card-body">
          <span style="display: inline-flex;align-items: center;color: #161616;
            font-family: Montserrat;
            font-size: 20px;
            font-weight: 700;
            line-height: 24px; margin-right: 36px;">
            <span >{{ upChain.symbol }}</span>
            <el-input-number size="medium" style="margin-left: 24px;font-size: 20px;" v-model="num" :precision="6" :step="0.1" :max="Math.max(upChain.balance-gas,0)"></el-input-number>
          </span>
          <el-button size="small" type="info" @click="toMax">MAX</el-button>
        </div>
       
      </div>

      <div style="position: absolute;margin-top: 10px;text-align: center;z-index: 1;width: 100%;left: 0;">
        <el-button type="primary" plain class="swi-btn"  @click="switchNet()">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true" class="text-dark"><path stroke-linecap="round" stroke-linejoin="round" d="M3 7.5L7.5 3m0 0L12 7.5M7.5 3v13.5m13.5 0L16.5 21m0 0L12 16.5m4.5 4.5V7.5"></path></svg>
        </el-button>
      </div>

      <div class="card2">
        <div class="card-header">
          <span class="card2-t1">To:
            <span style="color: #FFD016;font-size: 16px;font-weight: 700;">{{downChain.name}}</span>
          </span>
          <span class="card2-t1">Balance:
            <span style="color: #FFD016;font-size: 16px;font-weight: 700;">{{toFixed4(downChain.balance)}} {{downChain.symbol}}</span>
            </span>
        </div>
        <div class="card-body">
          <span style="display: inline-flex;align-items: center;font-weight: bold;font-size: 22px;">
            <span class="card2-t2" >{{ downChain.symbol }}</span>
            <el-input
              type="textarea"
              :autosize="{ minRows: 2, maxRows: 4}"
              placeholder="Enter collection address"
              v-model="toAddress"
              style="margin-left: 12px;font-size: 14px;border-radius: 12px;width: 320px;"
              >
            </el-input>
          </span>
          
        </div>
      </div>
      <div style="position: relative;text-align: center;margin-top: 36px;">

        <el-button :loading="isLoading" :disabled="isdisBridge()" size="medium" style="width: 100%;    height: 48px;" type="primary" @click="toBridge">{{isLoading?'Pending...':'Bridge'}}</el-button>
      </div>

      <div v-if="success.isShow" class="success-dev">
        <div class="t1">{{ success.content }}</div>
        <div class="t1">{{ success.content2 }}</div>
        <div class="t2" @click="jump">Click here to view the transaction.</div>

      </div>
      
    </div>

      
  </div>
</template>

<style lang="less" >
.container{
  // min-height: 800px;
  position: relative;
  margin: 36px auto;

  .success-dev{
    position: relative;
    text-align: center;
    padding: 16px;
    margin-top: 32px;
    border-radius: 10px;
    background: rgba(255, 201, 2, 0.15);
    .t1{
      color: #FFF;
      font-family: TWK Everett;
      font-size: 14px;
      font-weight: 400;
    }
    .t2{
      cursor: pointer;
      color: #FFD016;
      font-family: TWK Everett;
      font-size: 14px;
      font-weight: 400;
      text-decoration-line: underline;
    }
  }
  
  .swi-btn{
    width: 60px;height: 60px;padding: 12px;
    transition-duration: .2s;
    border-radius: 60px;
  }
  .swi-btn:hover{
    transform: rotate(180deg);
  }
  .p1{
    position: relative;
    border-radius: 24px;
    background-color: #0D0D0D;
    min-width: 820px;
    padding: 54px;
    width: 60%;
    margin: 0 auto;
    color: white;

    .p1-t1{
      color: rgba(255, 255, 255, 0.50);
      font-weight: 400;
      line-height: 24px;
    }
    .p1-t2{
      color: #84FBFC;
      font-weight: 400;
      line-height: 24px;
      font-size: 14px;
    }
    .p1-t3{
      color: #FFD016;
      font-weight: 400;
      line-height: 24px;
    }
    

    .card0{
      position: relative;
      border-radius: 24px;
      background: linear-gradient(92deg, #181818 1.94%, rgba(24, 24, 24, 0.50) 100%);
      padding: 28px 32px;
      color: #FFF;
      display: flex;
      justify-content: space-between;

      font-family: Montserrat;
      font-size: 16px;
      font-weight: 700;
      line-height: 24px; 
    }
    .card1{
      position: relative;
      background: #FFD016;
      border-radius: 24px;
      padding: 28px 32px;
      margin-top: 32px;

      display: flex;
      justify-content: space-between;
      align-items: center;

      .card1-t1{
        color: rgba(22, 22, 22, 0.70);
        font-family: Montserrat;
        font-size: 16px;
        font-weight: 400;
        line-height: 24px; 
      }
    }
    .card-header{
        position: relative;
        display: inline-flex;
        flex-direction: column;
        align-items: flex-start;
      }
      .card-body{
        position: relative;
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
    .card2{
      position: relative;
      border-radius: 24px;
      border: 1px solid #FFD016;
      padding: 28px 32px;
      margin-top: 80px;

      display: flex;
      justify-content: space-between;
      align-items: center;

      .card2-t1{
        color: rgba(255, 208, 22, 0.60);
        font-family: Montserrat;
        font-size: 16px;
        font-weight: 400;
        line-height: 24px; 
      }
      .card2-t2{
        color: #FFD016;
        font-family: Montserrat;
        font-size: 20px;
        font-weight: 700;
        line-height: 24px; 
        white-space: nowrap;
      }
      .card-body{
      }
    }

   

  }
}


</style>

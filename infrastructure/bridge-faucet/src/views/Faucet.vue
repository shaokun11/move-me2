<template>
   <div class="container">
        <div class="p1">

            <div class="conw">
                <div class="t1">Feel free to get MOVE to your wallet</div>
                <div class="t2">
                    <el-input
                        type="textarea"   
                        :autosize="{ minRows: 2, maxRows: 4}"
                        placeholder="Input your testnet MOVE address"
                        v-model="publicKey"
                        style="font-size: 14px;border-radius: 12px;"
                        >
                    </el-input>
                </div>
                <div>
                    <el-button :loading="isLoading" :disabled="isFaucet()" size="medium" style="width: 100%;    height: 48px;" type="primary" @click="getMove">{{ isLoading?'Requesing...':'Request' }}</el-button>
                </div>
                <div v-if="success.isShow" class="success-dev">
                    <div class="dev-t1">{{ success.content }}</div>
                    <div class="dev-t2" @click="jump">Click here to view the transaction.</div>

                </div>
            </div>

        </div>
    </div>
</template>
<script>
import {getMov} from '../scripts/utils/petra'
import {trace,replaceStr} from '../scripts/utils/tools'
import {mapGetters} from 'vuex'
const env = process.env;
export default {
    name: 'faucet',
    data() {
        return{
            isLoading:false,
            publicKey:'',
            Env:env,
            success:{
                isShow:false,
                from:'optos',//  optos/evm
                content:'100 MVMT successfully sent to 0x3c5...7AA0.',
                hash:'',
            },
        }

    },
    watch:{
        aptAccount(val){
            if(val&&!this.publicKey){
                this.publicKey = this.aptAccount.address
            }
        }
    },
    created(){
        if(this.aptAccount){
            this.publicKey = this.aptAccount.address
        }
    },
    computed: {
    ...mapGetters(["aptAccount"]),
      
    },
    methods:{
        showToast:function(content,type='success'){
            this.$message({
                message: content,
                type: type||'success',
                duration:4500
                });
        },
        isFaucet(){
            const str = this.publicKey.trim();
            return !str||str.length!=66;
        },
        async getMove(){
            this.isLoading = true;
            let res = await getMov(this.publicKey);
            this.isLoading = false;
            if(res&&res.length==1&&res[0].length==66){
                this.showToast('Request success.')
                this.showSuccessDev(res[0]);
            }
            trace('getMove-res',res);
        },
        showSuccessDev(hash){
            this.success.hash = hash;
            this.success.content = '10 MVMT successfully sent to '+replaceStr(this.publicKey)+'.';
            this.success.isShow = true;
        },
        jump(){
            if(this.success.isShow){
                window.open(Env.VUE_APP_EXPLORER+'/#/txn/'+this.success.hash+'?network=local');
               
            }
        },
    }
}
</script>

<style lang="less" scoped>
.container{
  // min-height: 800px;
  position: relative;
  margin: 36px auto;

  .p1{
    position: relative;
    border-radius: 24px;
    background-color: #0D0D0D;
    min-width: 820px;
    min-height: calc(100vh - 360px);
    padding: 54px;
    width: 60%;
    margin: 0 auto;
    display: flex;
    justify-content: center; 

    .conw{
        position: relative;
        width: 496px;
        text-align: center;
        .t1{
            color: #FFF;
            font-family: Montserrat;
            font-size: 32px;
            font-weight: 700;
        }
        .t2{
            margin: 48px 0;
        }
        .t3{}

        .success-dev{
        position: relative;
        text-align: center;
        padding: 16px;
        margin-top: 32px;
        border-radius: 10px;
        background: rgba(255, 201, 2, 0.15);
        .dev-t1{
        color: #FFF;
        font-family: TWK Everett;
        font-size: 14px;
        font-weight: 400;
        }
        .dev-t2{
        cursor: pointer;
        color: #FFD016;
        font-family: TWK Everett;
        font-size: 14px;
        font-weight: 400;
        text-decoration-line: underline;
        }
    }

    }

   

   }

   
}

</style>
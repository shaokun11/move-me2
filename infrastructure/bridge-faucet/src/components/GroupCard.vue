<!-- @author middear -->

<script>
import {mapGetters} from 'vuex'
import {buy} from '../scripts/utils/sdk'
export default {
  name: 'GroupCard',
  data() {
    return {
        isLoading:false,
    }
  },
  props: {
    id:0,
    name:'',
    nums:0,
    total:0.00,
    price:0.00,
    
  },
  methods:{
    showToast:function(content,type='success'){
      this.$message({
          message: content,
          type: type||'success',
          duration:3500
        });
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
    send(){
        console.log(this.account,this.id,this.nums+1)
        this.isLoading =true;
        buy(this.account,this.id,this.nums+1,"0x706AE1eD4c715cc3BFB077174a68999022C09f2e",(code,hash)=>{
            console.log(code,hash)
            this.isLoading =false;
            if(code===1){
                this.showToast('Buy successfully.');
            }else if(code===0){
                this.showToast('Buy sending...','info');
            }
        })
        
    }
  },
  computed: {
    ...mapGetters(["account",'network']),
      
    }
}
</script>

<template>
    <div :class="$style.card1" >
        <div :class="$style.card1_img_con">
            <img :class="$style.card1_img" src="../assets/icon_p.png" />
        </div>
        
        <div :class="$style.card1_con">
            <div style="margin-top: 18px;" :class="$style.card1_t1">{{name}}</div>
            <div style="margin-top: 34px;" :class="$style.card1_t2">
                <svg xmlns="http://www.w3.org/2000/svg" width="21" height="21" viewBox="0 0 21 21" fill="none">
                    <path d="M1.00186 19.6155C1.00186 19.8278 1.17904 20 1.39761 20L19.6012 20C19.8197 20 19.9969 19.8279 19.9969 19.6157V19.1565C20.006 19.0182 20.0245 18.3277 19.5694 17.5644C19.2824 17.0831 18.8659 16.6673 18.3314 16.3286C17.6848 15.9189 16.8623 15.622 15.8674 15.4432C15.86 15.4423 15.1223 15.3445 14.3666 15.1515C13.0505 14.8153 12.9355 14.5178 12.9347 14.5149C12.927 14.4855 12.9158 14.4573 12.9014 14.4307C12.8907 14.3752 12.8641 14.1664 12.9149 13.6068C13.044 12.1855 13.8064 11.3455 14.419 10.6706C14.6122 10.4577 14.7947 10.2567 14.9352 10.0595C15.5414 9.20905 15.5976 8.24195 15.6002 8.182C15.6002 8.06055 15.5862 7.9607 15.5564 7.86815C15.4969 7.68295 15.3849 7.56755 15.3032 7.4833L15.3026 7.4827C15.282 7.4615 15.2626 7.4414 15.2467 7.42295C15.2406 7.4159 15.2245 7.39725 15.2392 7.3015C15.293 6.94905 15.3253 6.65395 15.3408 6.3728C15.3684 5.8719 15.3899 5.1228 15.2607 4.39375C15.2448 4.26925 15.2174 4.13775 15.1747 3.9811C15.0382 3.47907 14.8189 3.04985 14.5142 2.69562C14.4618 2.63861 13.1878 1.2964 9.4894 1.021C8.978 0.982929 8.47245 1.00344 7.9748 1.02887C7.85485 1.0348 7.6906 1.04294 7.5369 1.08277C7.15505 1.18168 7.05315 1.42371 7.0264 1.55917C6.98205 1.78354 7.06 1.95807 7.11155 2.07359C7.11905 2.09033 7.1283 2.11106 7.11215 2.16498C7.0263 2.29794 6.89125 2.4178 6.75355 2.53136C6.71375 2.56519 5.78635 3.36484 5.73535 4.40945C5.59785 5.2039 5.60825 6.4417 5.77085 7.2972C5.7803 7.34445 5.79425 7.4144 5.7716 7.46165C5.59675 7.61835 5.39855 7.79595 5.39905 8.2012C5.40115 8.24195 5.4574 9.20905 6.0636 10.0595C6.204 10.2565 6.3863 10.4574 6.57935 10.6701L6.5798 10.6706C7.1924 11.3455 7.95475 12.1855 8.0839 13.6067C8.1347 14.1663 8.1081 14.3752 8.09735 14.4307C8.083 14.4572 8.0718 14.4855 8.0641 14.5149C8.0633 14.5178 7.9487 14.8143 6.6386 15.1498C5.8828 15.3433 5.13875 15.4422 5.11655 15.4454C4.1497 15.6086 3.33219 15.8981 2.68676 16.3057C2.15407 16.6422 1.73677 17.0588 1.44645 17.5438C0.982587 18.319 0.995127 19.0248 1.00186 19.1537V19.6155Z" fill="white" stroke="#333333" stroke-width="2" stroke-linejoin="round"/>
                </svg>
                <span>{{ nums }}</span>
            </div>
            <div style="margin-top: 20px;" :class="$style.card1_t2">
                <img src="../assets/icon_ETH.png" alt="" />
                <span>{{ total }}</span>
            </div>
            <div style="margin-top: 34px;" :class="$style.card1_t1">Price:{{price}}</div>
            
        </div>
        <div style="margin-top: 14px;">
            <el-button :loading="isLoading" :disabled="id==0" style="width: 100%;" type="primary" round><span :class="$style.card1_btn" @click="send">Send ETH</span></el-button>
        </div>
    </div>

</template>


<style lang="less" module>
.card1{
  position: relative;
  padding: 24px 20px ;
  border-radius: 30px;
  background: #2D2D2D;
  width: 212px;
  overflow: hidden;

  text-align: center;

  color: #FFF;
  font-family: PingFang SC;
}
.card1:hover{
    .card1_img{
        transform: scale(1.2);
    }
}
.card1_con{
    position: relative;
    text-align: center;
}
.card1_img_con{
    margin: 0 auto;
    width: 52px;
    img{
        width: 100%;
    }
}

.card1_img{
  width:100%;
  transition: all .5s ease .1s;
}



.card1_t1{
    font-size: 14px;
    font-weight: 600;
}
.card1_t2{
    font-size: 22px;
    font-weight: 600;

    display: flex;
    align-items: center;
    justify-content: center;

    img{
        height: 22px;
        margin-right: 6px;
    }
}
.card1_btn{
    font-size: 14px;
    font-weight: 600;
}

</style>

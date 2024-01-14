<!-- @author middear -->

<script>
export default {
  name: 'Footer',
  props: {
    
   
  },
}
</script>

<template>
    <div class="con-f">
        <div class="p1">
            <span>
                <img src="@/assets/logo_txt.png" alt=""  />
            </span>
            <span>
                <el-menu class="nav0" 
                    mode="horizontal"
                    background-color="black"
                    text-color="white"
                    active-text-color="white"
                    router
                    >
                    <el-menu-item index="/" >Projects</el-menu-item>
                    <el-menu-item index="/staking">Staking</el-menu-item>
                </el-menu>
            </span>
            
        </div>
        <div class="p2">
            <div class="p2-navs">
                <a target="_blank" href="//www.google.com">
                    <img src="@/assets/icon_twitter.svg" alt="" />
                </a>
                <a target="_blank" href="//www.google.com" style="margin:0 40px;">
                    <img src="@/assets/icon_telegrm.svg" alt="" />
                </a>
                <a target="_blank" href="//www.google.com">
                    <img src="@/assets/icon_discord.svg" alt="" />
                </a>
            </div>
            <div style="margin-top:10px;">© 2023 Quill All rights reserved</div>
        </div>
      
    </div>

</template>


<style lang="less" >
.con-f{
    min-height: 240px;
    background: #000;
    position: relative;
    padding: 40px 56px;
    color: #fff;
    .p1{
        position: relative;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .p2{
        position: relative;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        margin-top: 65px;
        opacity: 0.5;

        .p2-navs{
        
        a{
            img{
                width: 24px;
                transition: all .5s ease .1s;
            }
        }
        a:hover{
            img{
                transform: scale(1.2);
            }
        }
    }
    }
   

    .nav0{
        border: 0 !important;
    }
    .el-menu.el-menu--horizontal {
        border-bottom: solid 0.0625rem #000000 !important;
    }
   
}



    

    


</style>

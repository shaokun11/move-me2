
export default {
  namespaced: true,
  state: {
    account: null,
    network: '',
    showConnect:false,
    showSwitchNet:false,
    icon:'',
    aptAccount:null,
  },
  getters: {
    //   user: state => {
    //     if (!state.user) {
    //       try {
    //         const user = localStorage.getItem(process.env.VUE_APP_USER_KEY)
    //         state.user = JSON.parse(user)
    //       } catch (e) {
    //         console.error(e)
    //       }
    //     }
    //     return state.user
    //   },
  },
  mutations: {
    login(state) {},
    disconnect(state) {
      state.account = null
    },
    setNetwork(state, n) {
        state.network = n;
    },
    
    setshowConnect(state,b){
      state.showConnect = b;
    },
    setshowSwitchNet(state,b){
      state.showSwitchNet = b;
    },

    setAccount(state,account){
      state.account = account
    },
    setAptAccount(state,account){
      state.aptAccount = account
    },
    setIcon(state,icon){
      state.icon = icon
    },

    setUser(state, user) {
      state.user = user
      localStorage.setItem(process.env.VUE_APP_USER_KEY, JSON.stringify(user))
    },
  },
}

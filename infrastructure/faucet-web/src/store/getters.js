const getters = {
    icon:state=>state.user.icon,
    account:state=>state.user.account,
    aptAccount:state=>state.user.aptAccount,
    network:state=>state.user.network,
    showConnect:state=>state.user.showConnect,
    showSwitchNet:state=>state.user.showSwitchNet,
}
export default getters
import React, {useRef} from "react";
import Toolbar from "@mui/material/Toolbar";
import MuiAppBar from "@mui/material/AppBar";
import Container from "@mui/material/Container";
import NetworkSelect from "./NetworkSelect";
import {useColorMode} from "../../context";
import {useMediaQuery, useTheme} from "@mui/material";
import {ReactComponent as LogoIconW} from "../../assets/svg/logo_txt_w.svg";
import {ReactComponent as LogoIconB} from "../../assets/svg/logo_txt_b.svg";
import {ReactComponent as IconLight} from "../../assets/svg/icon_light.svg";
import {ReactComponent as IconDark} from "../../assets/svg/icon_dark.svg";
import Button from "@mui/material/Button";
import Box from "@mui/material/Box";
import Nav from "./Nav";
import NavMobile from "./NavMobile";
import {grey} from "../../themes/colors/aptosColorPalette";
import {useInView} from "react-intersection-observer";
import FeatureBar from "./FeatureBar";
import {WalletConnector} from "@aptos-labs/wallet-adapter-mui-design";
import {useGlobalState} from "../../global-config/GlobalConfig";
import {useWallet} from "@aptos-labs/wallet-adapter-react";
import {sendToGTM} from "../../api/hooks/useGoogleTagManager";
import {Statsig} from "statsig-react";
import {Link, useNavigate} from "../../routing";

export default function Header() {
  const scrollTop = () => {
    const docElement = document.documentElement;
    const windowTop =
      (window.pageYOffset || docElement.scrollTop) -
      (docElement.clientTop || 0);

    if (windowTop > 0) {
      window.scrollTo({
        top: 0,
        behavior: "smooth",
      });
    }
  };

  const {toggleColorMode} = useColorMode();
  const theme = useTheme();
  const isDark = theme.palette.mode === "dark";

  const {ref, inView} = useInView({
    rootMargin: "-40px 0px 0px 0px",
    threshold: 0,
  });

  const isOnMobile = !useMediaQuery(theme.breakpoints.up("md"));
  const [state] = useGlobalState();
  const {account, wallet, network} = useWallet();
  const navigate = useNavigate();
  let walletAddressRef = useRef("");

  if (account && walletAddressRef.current !== account.address) {
    Statsig.logEvent("wallet_connected", account.address, {
      wallet_name: wallet!.name,
      network_type: state.network_name,
    });
    sendToGTM({
      dataLayer: {
        event: "walletConnection",
        walletAddress: account.address,
        walletName: wallet?.name,
        network: network?.name,
      },
    });
    walletAddressRef.current = account.address;
  }

  return (
    <>
      <Box
        sx={{
          background: "transparent",
          height: "5rem",
          width: "100%",
          position: "absolute",
        }}
        ref={ref}
      ></Box>
      <MuiAppBar
        sx={{
          position: "sticky",
          top: "0",
          borderRadius: "0",
          backdropFilter: "blur(10px)",
          background: "transparent",
          ...(!inView &&
            isDark && {
              background: "rgba(18,22,21, 0.85)",
              borderBottom: `1px solid ${theme.palette.common}`,
            }),
          ...(!inView &&
            !isDark && {
              background: "rgba(254,254,254, 0.8)",
              borderBottom: `2px solid rgba(18,22,21,0.05)`,
            }),
        }}
      >
        <FeatureBar />
        <Container maxWidth={false}>
          <Toolbar
            sx={{
              height: "5rem",
              color:
                theme.palette.mode === "dark" ? grey[50] : "rgba(18,22,21,1)",
            }}
            disableGutters
          >
            <Link
              onClick={scrollTop}
              to="/"
              color="inherit"
              underline="none"
              sx={{
                // width: {xs: "30px", sm: "30px", md: "40px"},
                height: {xs: "30px", sm: "30px", md: "40px"},
                marginRight: "auto",
                display:'inline-flex',
                alignItems:'center'
              }}
            >
              {
                isDark?
                <LogoIconW style={{
                      // width: 'auto',
                      // height: '26',
                      // border: '1px solid white',
                      // borderRadius: '50%',
                      width: '221px',
                      height: '35px',
                }} />
                :
                <LogoIconB style={{
                      // width: 'auto',
                      // height: '26',
                      // border: '1px solid white',
                      // borderRadius: '50%',
                      width: '221px',
                      height: '35px',
                }} />
              }
              {/* <Box component={'span'} sx={{ml:'8px',fontWeight:'bold'}}>Movement</Box> */}
            </Link>

            {/*<Nav />*/}
            {/* <NetworkSelect /> */}
            <Button
              onClick={toggleColorMode}
              sx={{
                
                width: "30px",
                height: "30px",
                display: "flex",
                alignItems: "center",
                justifyItems: "center",
                padding: "0",
                minWidth: "30px",
                marginLeft: "1rem",
                color: "inherit",
                "&:hover": {background: "transparent", opacity: "0.8"},
              }}
            >
              {theme.palette.mode === "light" ? <IconLight /> : <IconDark />}
            </Button>
            {/*<NavMobile />*/}
            {!isOnMobile && (
              <Box sx={{
                marginLeft: "1rem",
                '& button':{
                  borderRadius:'0 !important',
                  color:'white !important',
                  backgroundColor:'#1737FF',
                  '&:hover':{backgroundColor:'rgb(16, 38, 178)'},
                }
                }}>
                {/*<WalletConnector
                  networkSupport={state.network_name}
                  handleNavigate={() =>
                    navigate(`/account/${account?.address}`)
                  }
                />*/}
              </Box>
            )}
          </Toolbar>
        </Container>
      </MuiAppBar>
    </>
  );
}

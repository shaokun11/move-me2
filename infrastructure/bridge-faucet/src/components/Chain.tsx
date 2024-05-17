import React, { useEffect } from "react";
import Box from "@mui/material/Box";
import Button from "@mui/material/Button";
import { useState,RefObject } from "react";
import WaterDropIcon from '@mui/icons-material/Opacity';
// import { to } from "await-to-js";
import TextField from "@mui/material/TextField";
import Container from "@mui/material/Container";
import Alert from "@mui/material/Alert";
import CircularProgress from "@mui/material/CircularProgress";
// import { AptosClient, FaucetClient, CoinClient } from "aptos";
import { Switch } from "@mui/material";
import FormControlLabel from '@mui/material/FormControlLabel';
import { Network } from "../utils";
// import {ReCAPTCHA} from "@types/react-google-recaptcha";
import ReCAPTCHA from "react-google-recaptcha";
import {useMediaQuery, useTheme} from "@mui/material";
// import { set } from "lodash";

export default function LandingPage({ name, amount, hasEvm, faucetRequest, evmRequest, network, hasTestnet, toggleNetwork }: any) {

    const [mevm, setMevm] = useState(false);
    const [success, setSuccess] = useState(false);
    const [address, setAddress] = useState("");
    const [errorMessage, setErrorMessage] = useState<string | null>(null);
    const [loading, setLoading] = useState(false);
    const [token, setToken] = useState<string|null>(null);
    const theme = useTheme();
    const [isDark, setIsDark] = useState(theme.palette.mode === "dark");

    useEffect(() => {
        setIsDark(theme.palette.mode === "dark");
    }, [theme]);
    

    // decay the success state
    useEffect(() => {

        const timeout = setTimeout(() => {
            setSuccess(false);
            setErrorMessage(null);
        }, 3000);

        return () => {
            clearTimeout(timeout);
        };

    }, [success, errorMessage]);


    const handleRequest = async () => {
        setLoading(true);
        recaptchaRef.current?.reset();
        setToken(null);
        const res = mevm ? await evmRequest(address,token) : await faucetRequest(address,token);
        // console.log('res=',res);
        if (res && res.success) {
            setSuccess(true);
        } else{
            setErrorMessage(res.error || "Failed to fund account.");
        }
        setLoading(false);
    };

    const handleFormSubmit = (event: React.FormEvent) => {
        event.preventDefault();
        handleRequest(); // Use the wrapper method
    };

    const isValidHex = (str: string, fractal = false) => {
        const regex = mevm ? fractal ? /^0x[a-fA-F0-9]{40}$/ : /^0x[a-fA-F0-9]{64}$/ : /^0x[a-fA-F0-9]{64}$/;
        return regex.test(str);
    };

    const _amount = mevm ? 1 : amount;

    // const widgetId3 = (window as any).grecaptcha.render(document.getElementById('example3'), {
    //     'sitekey' : '6LeNltspAAAAAECHmsdf8w29UFF3ZiIrvscSkMTi',
    //     'callback' : verifyCallback,
    //     'theme' : 'light'
    // });
    const onChangeRe = (value:string|null)=> {
        // console.log("Captcha value:", value);
        setToken(value);
      }

    const recaptchaRef: RefObject<ReCAPTCHA> = React.createRef();

    const onSubmitWithReCAPTCHA = async () => {
        const token = recaptchaRef.current?.getValue();
        // console.log(token);
    }
      

    // const handleSubmit = () => {
    //     const recaptchaValue = recaptchaRef.current?.getValue();
    // };

    return (
        <Container sx={{ position: 'relative' }}>
            <Box
                sx={{
                    display: "flex",
                    flexDirection: "column",
                    alignItems: "center",
                    justifyContent: "center",
                    height: "100%",
                    poisition: 'relative'
                }}
            >
                <div style={{ width: "300px" }}>
                    <h1 style={{ textAlign: "left" }}>{name}</h1>
                </div>

                <form name={name} onSubmit={handleFormSubmit}>
                    <TextField
                        label={name + " Account Address"}
                        variant="outlined"
                        value={address}
                        onChange={(e) => setAddress(e.target.value)}
                        sx={{ width: 300, marginBottom: 2 }}
                        disabled={loading}
                        error={!isValidHex(address, true) && address !== ""}
                        helperText={!isValidHex(address, true) && address !== "" ? `Invalid address. Should be of the form: 0xab12... and be ${mevm ? '20' : '32'} bytes in length` : ""}
                    />
                    <br />
                    {hasTestnet && <FormControlLabel
                        control={<Switch checked={network == Network.Testnet} onChange={() => toggleNetwork()} />}
                        label={"Testnet"}
                        sx={{ marginBottom: 2 }}
                    />}
                    {hasEvm && <FormControlLabel
                        control={<Switch checked={mevm} onChange={() => setMevm(!mevm)} />}
                        label="MEVM account"
                        sx={{ marginBottom: 2 }}
                    />}
                    <br />

                    {loading && <CircularProgress sx={{ position: 'absolute', left: '50%' }} />}

                    <Button
                        onClick={handleRequest}
                        variant="contained"
                        sx={{
                            width: 300,
                            borderRadius: 0,
                            color: 'white',
                            backgroundColor: '#1737FF',
                            '&:hover': { backgroundColor: 'rgb(16, 38, 178)' }
                        }}
                        disabled={loading||token===null||!isValidHex(address, true)}
                    >
                        <WaterDropIcon sx={{ mr: 1 }} />
                        Get MOVE
                    </Button>
                    <div>
                        {/* <form onSubmit={onSubmitWithReCAPTCHA} > */}
                                {isDark &&
                                <ReCAPTCHA
                                    ref={recaptchaRef}
                                    sitekey="6LeNltspAAAAAECHmsdf8w29UFF3ZiIrvscSkMTi"
                                    // size="invisible"
                                    hl="en"
                                    onChange={onChangeRe}
                                    theme="dark"
                                />}
                                {!isDark &&
                                    <ReCAPTCHA
                                        ref={recaptchaRef}
                                        sitekey="6LeNltspAAAAAECHmsdf8w29UFF3ZiIrvscSkMTi"
                                        // size="invisible"
                                        hl="en"
                                        onChange={onChangeRe}
                                        theme="light"
                                    />
                                }
                        {/* </form> */}
                    </div>
                    {success && <Alert severity="success" sx={{ width: 300, marginBottom: 2 }}>Funded account {_amount} MOVE</Alert>}
                    {errorMessage && <Alert severity="error" sx={{ width: 300, marginBottom: 2 }}>{errorMessage}</Alert>}
                </form>
            </Box>
        </Container>
    );
}

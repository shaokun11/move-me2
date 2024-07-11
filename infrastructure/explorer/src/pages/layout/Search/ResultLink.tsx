import React from "react";
import {Typography} from "@mui/material";
import {Link} from "../../../routing";
import SouthIcon from '@mui/icons-material/South';

type ResultLinkProps = {
  to: string | null;
  text0: string | null;
  text: string;
};

export default function ResultLink({to, text,text0}: ResultLinkProps): JSX.Element {
  const style = {
    padding: 0.5,
    display: "block",
    width: "100%",
    "&:hover": {
      backgroundColor: `${"transparent"}!important`,
      opacity: "0.8",
    },
  };

  if (!to) {
    return (
      <Typography color="inherit" sx={style}>
        {text}
      </Typography>
    );
  }
  if(text0){
    return(
      <Link to={to} className="bobobo" color="inherit" underline="none" sx={style}>
        <div style={{opacity:0.65}}>{text0}</div>
        <SouthIcon style={{marginLeft:"24px",marginTop:"6px"}} fontSize="small"> </SouthIcon>
        <div>{text}</div>
      </Link>
    )
  }

  return (
    <Link to={to} color="inherit" underline="none" sx={style}>
      {text}
    </Link>
  );
}

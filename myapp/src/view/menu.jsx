import React from "react";
import { NavLink } from "react-router-dom";
import style from "./menu.module.css";

// import { NavLink } from "react-router-dom";

export default function Menu(props) {
    console.log(props);
    console.log(props.routeArr);


    return (
        <div >
            <div className={style["menu"]}>
                {
                    props.routeArr.map((item) => {
                        return <div key={item.path} className={style["menu-item"]}>
                            <NavLink className={(obj) => {
                                return obj.isActive ? style["menu-on"] : style["nav-link"]
                            }} to={item.path}>{item.name}</NavLink>
                        </div>
                    })
                }
            </div>

        </div >
    )
}
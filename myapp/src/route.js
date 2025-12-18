import Add from "./pages/add";
import Remove from "./pages/remove";
import Seft from "./pages/seft";
import Stfe from "./pages/stfe";

export default [
    {
        path: "/",
        name: "添加流动性",
        element: Add
    },
    {
        path: "/remove",
        name: "移除流动性",
        element: Remove
    },
    {
        path: "/seft",
        name: "换入确定的代币",
        element: Seft
    },
    {
        path: "/stfe",
        name: "换出确定的代币",
        element: Stfe
    }
]
import React, { useEffect } from 'react'
import Web3 from 'web3'
import tokenAjson from '../out/TokenA.sol/TokenA.json'
import tokenBjson from '../out/TokenB.sol/TokenB.json'
import pairjson from '../out/UniswapV2Pair.sol/UniswapV2Pair.json'
import factoryjson from '../out/UniswapV2Factory.sol/UniswapV2Factory.json'
import routerjson from '../out/UniswapV2Router.sol/UniswapV2Router.json'
import deploy from '../broadcast/run-latest.json'
import Order from './Order'
import Balance from './Balance'
import { useDispatch } from "react-redux";
import { loadBalanceData } from '../redux/slices/balanceSlice'
import routeArr from '../route'
import Menu from './menu'
import { BrowserRouter, Route, Routes } from 'react-router-dom';

export default function Content() {
    const dispatch = useDispatch();

    useEffect(() => {
        async function start() {
            //1.获取链接后的合约
            const web = await initWeb()

            //web3：Web3.js实例包含大量方法和内部状态，无法序列化
            //web为不可序列化对象，不能直接存入Redux
            // console.log(web);

            //解决方案
            //useContext , useReducer
            //订阅发布
            //设置成全局
            window.web = web;
            // console.log(window.web);

            //2.获取资产信息
            dispatch(loadBalanceData(web))

            //3.获取订单信息
        }
        start()
    }, [dispatch])

    async function initWeb() {
        //Web3.givenProvider
        //本代码 - web3.js - 钱包provider - 节点 - 区块链网络
        //能够拿到 “用户明确同意暴露的账户”
        //作用：绑定 provider，准备发 RPC 请求
        //不会自动请求账户，不会弹钱包，可能拿不到任何 account

        //http://localhost:8545
        //本代码 - web3.js - HTTP Provider - 节点 - 区块链网络
        //能够拿到 节点本地管理的测试账户

        //让你的代码“具备通过web3向区块链节点发 RPC 请求的能力”
        var web3 = new Web3(Web3.givenProvider || "http://localhost:8545")
        // console.log(web3);

        //能够拿到 节点本地管理的测试账户,只是预置的几个私钥
        // let chainAccounts = await web3.eth.getAccounts()

        //让钱包弹窗，请用户授权账户给当前 DApp，只能拿到「用户授权给当前 DApp 的钱包地址」
        let accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });

        // console.log(tokenAjson);

        const tokenAabi = tokenAjson.abi;
        const tokenBabi = tokenBjson.abi;
        const pairabi = pairjson.abi;
        const factoryabi = factoryjson.abi;
        const routerabi = routerjson.abi;

        // console.log(deploy);
        let tokenAaddress;
        let tokenBaddress;
        let pairaddress;
        let routeraddress;
        let factoryaddress;

        /** map的用法
         * 
         *  const userSummaries = users.map(user => ({
                fullName: user.name,
                isAdult: user.age >= 18
            }));

            console.log(userSummaries);

            [{fullName: "Alice", isAdult: true}, {fullName: "Bob", isAdult: true}]
         * 
         */
        deploy.transactions.forEach((item) => {
            if (item.contractName === "TokenA") {
                tokenAaddress = item.contractAddress;
            } else if (item.contractName === "TokenB") {
                tokenBaddress = item.contractAddress;
            } else if (item.contractName === "UniswapV2Router") {
                routeraddress = item.contractAddress;
            } else if (item.contractName === "UniswapV2Factory") {
                factoryaddress = item.contractAddress;
            }
        })

        const tokenA = await new web3.eth.Contract(tokenAabi, tokenAaddress)
        const tokenB = await new web3.eth.Contract(tokenBabi, tokenBaddress)
        const factory = await new web3.eth.Contract(factoryabi, factoryaddress)
        const router = await new web3.eth.Contract(routerabi, routeraddress)

        //获得pair合约的实例
        try {
            pairaddress = await factory.methods.getPair(tokenA._address, tokenB._address).call();
            if (pairaddress == '0x0000000000000000000000000000000000000000') {
                await factory.methods.createPair(tokenA._address, tokenB._address).send({ from: accounts[0] });

                pairaddress = await factory.methods.getPair(tokenA._address, tokenB._address).call();
                // console.log('New pair created:', pairaddress);
            }
        } catch (error) {
            console.error('Error creating pair:', error);
        }
        const pair = await new web3.eth.Contract(pairabi, pairaddress)

        return {
            web3,
            account: accounts[0],
            tokenA,
            tokenB,
            pair,
            factory,
            router
        }
    }

    return (
        <div style={{ padding: "10px" }}>
            <Balance></Balance>
            {/* <BrowserRouter> */}
            <Menu routeArr={routeArr}></Menu>

            <Routes>
                {
                    routeArr.map((item, index) => {
                        return <Route key={item.path} path={item.path} element={<item.element />}></Route>
                    })
                }
            </Routes>
            {/* </BrowserRouter> */}
            {/* <Order></Order> */}
        </div >
    )
}

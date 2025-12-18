import React, { useRef, useState, useEffect } from 'react'
import { useDispatch } from 'react-redux'
import { loadBalanceData } from '../redux/slices/balanceSlice'
import { Card, Col, Row, Statistic, Button, Input, Space } from 'antd';

export default function Order() {
    const dispatch = useDispatch();
    //addliqulity
    const [amountADesired, setamountADesired] = useState();
    const [amountBDesired, setamountBDesired] = useState();
    const [amountAMin, setamountAMin] = useState();
    const [amountBMin, setamountBMin] = useState();
    const [deadline, setDeadline] = useState();

    //removeliqulity
    const [liquidity, setLiquidity] = useState();
    const [amountAMin2, setamountAMin2] = useState();
    const [amountBMin2, setamountBMin2] = useState();
    const [deadline2, setDeadline2] = useState();

    //swapExactTokensForTokens
    const [amountIn, setAmountIn] = useState();
    const [amountOutMin, setAmountOutMin] = useState();
    const [address1, setAddress1] = useState();
    const [address2, setAddress2] = useState();
    const [deadline3, setDeadline3] = useState();

    //swapTokensForExactTokens
    const [amountOut, setAmountOut] = useState();
    const [amountInMax, setAmountInMax] = useState();
    const [addr1, setAddr1] = useState();
    const [addr2, setAddr2] = useState();
    const [deadline4, setDeadline4] = useState();

    const toWei = (number) => {
        return number * 10 ** 18;
    }

    return (
        <div>
            <div style={{ marginTop: "10px", padding: "10px" }} >添加流动性</div>
            <Space.Compact style={{ width: '100%' }}>
                <Input placeholder="amountA Desired" value={amountADesired}
                    onChange={(e) => setamountADesired(e.target.value)} />
                <Input placeholder="amountB Desired" value={amountBDesired}
                    onChange={(e) => setamountBDesired(e.target.value)} />
                <Input placeholder="amountA Min" value={amountAMin}
                    onChange={(e) => setamountAMin(e.target.value)} />
                <Input placeholder="amountB Min" value={amountBMin}
                    onChange={(e) => setamountBMin(e.target.value)} />
                <Input placeholder="截至时间/分钟" value={deadline}
                    onChange={(e) => setDeadline(e.target.value)} />
                <Button type="primary" style={{ marginLeft: '10px' }} onClick={async () => {
                    const deadlineTimestamp = Math.floor(Date.now() / 1000) + (Number(deadline) * 60);

                    const { account, tokenA, tokenB, pair, factory, router } = window.web;

                    const bool1 = await tokenA.methods.approve(router._address, toWei(Number(amountADesired))).send({ from: account });

                    const bool2 = await tokenB.methods.approve(router._address, toWei(Number(amountBDesired))).send({ from: account });

                    const { amountA, amountB, liquidity } = await router.methods.addLiquidity(
                        tokenA._address,
                        tokenB._address,
                        toWei(Number(amountADesired)),
                        toWei(Number(amountBDesired)),
                        toWei(Number(amountAMin)),
                        toWei(Number(amountBMin)),
                        account,
                        deadlineTimestamp
                    ).send({ from: account });

                    dispatch(loadBalanceData(window.web));

                    setamountADesired('');
                    setamountBDesired('');
                    setamountAMin('');
                    setamountBMin('');
                    setDeadline('');
                }}>提交</Button>

            </Space.Compact>

            <div style={{ marginTop: "10px", padding: "10px" }} >移除流动性</div>
            <Space.Compact style={{ width: '100%' }}>
                <Input placeholder="liquidity" value={liquidity}
                    onChange={(e) => setLiquidity(e.target.value)} />
                <Input placeholder="amountA Min" value={amountAMin2}
                    onChange={(e) => setamountAMin2(e.target.value)} />
                <Input placeholder="amountB Min" value={amountBMin2}
                    onChange={(e) => setamountBMin2(e.target.value)} />
                <Input placeholder="截至时间/分钟" value={deadline2}
                    onChange={(e) => setDeadline2(e.target.value)} />
                <Button type="primary" style={{ marginLeft: '10px' }} onClick={async () => {
                    const deadlineTimestamp = Math.floor(Date.now() / 1000) + (Number(deadline2) * 60);

                    const { account, tokenA, tokenB, pair, factory, router } = window.web;

                    const bool = await pair.methods.approve(router._address, toWei(Number(liquidity))).send({ from: account });

                    const { amountA, amountB } = await router.methods.removeLiquidity(
                        tokenA._address,
                        tokenB._address,
                        toWei(Number(liquidity)),
                        toWei(Number(amountAMin2)),
                        toWei(Number(amountBMin2)),
                        account,
                        deadlineTimestamp
                    ).send({ from: account });

                    dispatch(loadBalanceData(window.web));

                    setLiquidity('');
                    setamountAMin2('');
                    setamountBMin2('');
                    setDeadline2('');
                }}>提交</Button>
            </Space.Compact>

            <div style={{ marginTop: "10px", padding: "10px" }} >用确定金额交换不定金额</div>
            <Space.Compact style={{ width: '100%' }}>
                <Input placeholder="amount In" value={amountIn}
                    onChange={(e) => setAmountIn(e.target.value)} />
                <Input placeholder="amount Out Min" value={amountOutMin}
                    onChange={(e) => setAmountOutMin(e.target.value)} />
                <Input placeholder="address1" value={address1}
                    onChange={(e) => setAddress1(e.target.value)} />
                <Input placeholder="address2" value={address2}
                    onChange={(e) => setAddress2(e.target.value)} />
                <Input placeholder="截至时间/分钟" value={deadline3}
                    onChange={(e) => setDeadline3(e.target.value)} />
                <Button type="primary" style={{ marginLeft: '10px' }} onClick={async () => {

                    const deadlineTimestamp = Math.floor(Date.now() / 1000) + (Number(deadline3) * 60);

                    const { account, tokenA, tokenB, pair, factory, router } = window.web;

                    if (address1 === tokenA._address) {
                        await tokenA.methods.approve(router._address, toWei(Number(amountIn))).send({ from: account });
                    } else if (address1 === tokenB._address) {
                        await tokenB.methods.approve(router._address, toWei(Number(amountIn))).send({ from: account });
                    } else {
                        return;
                    }

                    await router.methods.swapExactTokensForTokens(
                        toWei(Number(amountIn)),
                        toWei(Number(amountOutMin)),
                        [address1, address2],
                        account,
                        deadlineTimestamp
                    ).send({ from: account });

                    dispatch(loadBalanceData(window.web));

                    setAmountIn('');
                    setAmountOutMin('');
                    setAddress1('');
                    setAddress2('');
                    setDeadline3('');
                }}>提交</Button>
            </Space.Compact>

            {/* const [amountOut, setAmountOut] = useState();
    const [amountInMax, setAmountInMax] = useState();
    const [addr1, setAddr1] = useState();
    const [addr2 , setAddr2] = useState();
    const [deadline4, setDeadline4] = useState(); */}

            <div style={{ marginTop: "10px", padding: "10px" }} >用不定金额交换确定金额</div>
            <Space.Compact style={{ width: '100%' }}>
                <Input placeholder="amount Out" value={amountOut}
                    onChange={(e) => setAmountOut(e.target.value)} />
                <Input placeholder="amount In Max" value={amountInMax}
                    onChange={(e) => setAmountInMax(e.target.value)} />
                <Input placeholder="address1" value={addr1}
                    onChange={(e) => setAddr1(e.target.value)} />
                <Input placeholder="address2" value={addr2}
                    onChange={(e) => setAddr2(e.target.value)} />
                <Input placeholder="截至时间/分钟" value={deadline4}
                    onChange={(e) => setDeadline4(e.target.value)} />
                <Button type="primary" style={{ marginLeft: '10px' }} onClick={async () => {

                    const deadlineTimestamp = Math.floor(Date.now() / 1000) + (Number(deadline4) * 60);

                    const { account, tokenA, tokenB, pair, factory, router } = window.web;

                    if (addr1 === tokenA._address) {
                        await tokenA.methods.approve(router._address, toWei(Number(amountInMax))).send({ from: account });
                    } else if (addr1 === tokenB._address) {
                        await tokenB.methods.approve(router._address, toWei(Number(amountInMax))).send({ from: account });
                    } else {
                        return;
                    }

                    await router.methods.swapTokensForExactTokens(
                        toWei(Number(amountOut)),
                        toWei(Number(amountInMax)),
                        [addr1, addr2],
                        account,
                        deadlineTimestamp
                    ).send({ from: account });

                    dispatch(loadBalanceData(window.web));

                    setAmountOut('');
                    setAmountInMax('');
                    setAddr1('');
                    setAddr2('');
                    setDeadline4('');
                }}>提交</Button>
            </Space.Compact>
        </div>
    )
}
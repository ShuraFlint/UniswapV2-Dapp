import React, { useRef, useState, useEffect } from 'react'
import { useDispatch } from 'react-redux'
import { loadBalanceData } from '../redux/slices/balanceSlice'
import { Card, Col, Row, Statistic, Button, Input, Space } from 'antd';

export default function Stfe() {
    const dispatch = useDispatch();
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
            <div style={{ marginTop: "10px", padding: "10px" }} ></div>
            <Space.Compact style={{ width: '80%', height: '115px', display: 'flex', margin: '0 auto' }}>
                <Input placeholder="amount Out" value={amountOut} style={{ fontSize: '30px' }}
                    onChange={(e) => setAmountOut(e.target.value)} />
                <Input placeholder="amount In Max" value={amountInMax} style={{ fontSize: '30px' }}
                    onChange={(e) => setAmountInMax(e.target.value)} />
                <Input placeholder="address1" value={addr1} style={{ fontSize: '30px' }}
                    onChange={(e) => setAddr1(e.target.value)} />
                <Input placeholder="address2" value={addr2} style={{ fontSize: '30px' }}
                    onChange={(e) => setAddr2(e.target.value)} />
                <Input placeholder="截至时间/分钟" value={deadline4} style={{ fontSize: '30px' }}
                    onChange={(e) => setDeadline4(e.target.value)} />

            </Space.Compact>

            <div style={{ width: '100%', marginTop: '50px', height: '80px' }}>

                <Button type="primary" style={{ width: '40%', height: '80px', display: 'flex', margin: '0 auto', fontSize: '30px' }} onClick={async () => {

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
            </div>
        </div>
    )
}
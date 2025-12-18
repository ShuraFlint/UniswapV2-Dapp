import { React, useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { ArrowDownOutlined, ArrowUpOutlined } from '@ant-design/icons';
import { Card, Col, Row, Statistic } from 'antd';
import style from './menu.module.css'


function convert(n) {
    if (!window.web) return n
    return window.web.web3.utils.fromWei(n, 'ether');
}

export default function Balance() {
    const [contracts, setContracts] = useState(null);

    //state 可以使用 store中的所有的slice变量
    //因为store在App.js中已经注入到组件树中了
    const {
        TokenA, //wei转换需要字符串，不是数字
        TokenB,
        PairTokenA,
        PairTokenB,
        LP
    } = useSelector((state) => state.balance);

    useEffect(() => {
        // 等待window.web初始化
        const checkWeb = () => {
            if (window.web) {
                setContracts(window.web);
            } else {
                // 如果还没初始化，稍后重试
                setTimeout(checkWeb, 100);
            }
        };
        checkWeb();
    }, []);

    if (!contracts) {
        return <h3>正在加载合约信息...</h3>;
    }

    const { tokenA, tokenB } = contracts;

    //使用slice中的方法，可以直接修改state
    // const dispatch = useDispatch();
    return (
        <div>
            <div className={style["balance"]}>
                <h3 className={style["balance-item"]}>
                    tokenA合约地址： {tokenA._address}
                </h3>
                <h3 className={style["balance-item"]}>
                    tokenB合约地址： {tokenB._address}
                </h3>
            </div>

            <Row style={{ marginTop: "10px" }}>
                <Col span={5}>
                    <Card hoverable={true}>
                        <Statistic
                            title="用户在tokenA中的余额"
                            value={convert(TokenA)}
                            precision={2}
                            styles={{ content: { color: '#3f8600' } }}
                        // prefix={<ArrowUpOutlined />}
                        // suffix="%"
                        />
                    </Card>
                </Col>
                <Col span={5}>
                    <Card hoverable={true}>
                        <Statistic
                            title="用户在tokenB中的余额"
                            value={convert(TokenB)}
                            precision={2}
                            styles={{ content: { color: '#3f8600' } }}
                        // prefix={<ArrowDownOutlined />}
                        // suffix="%"
                        />
                    </Card>
                </Col>
                <Col span={4}>
                    <Card hoverable={true}>
                        <Statistic
                            title="用户的LP余额"
                            value={convert(LP)}
                            precision={2}
                            styles={{ content: { color: '#1677ff' } }}
                        // prefix={<ArrowDownOutlined />}
                        // suffix="%"
                        />
                    </Card>
                </Col>
                <Col span={5}>
                    <Card hoverable={true}>
                        <Statistic
                            title="pair中tokenA的数量"
                            value={convert(PairTokenA)}
                            precision={2}
                            styles={{ content: { color: '#cf1332' } }}
                        // prefix={<ArrowUpOutlined />}
                        // suffix="%"
                        />
                    </Card>
                </Col>
                <Col span={5}>
                    <Card hoverable={true}>
                        <Statistic
                            title="pair中tokenB的数量"
                            value={convert(PairTokenB)}
                            precision={2}
                            styles={{ content: { color: '#cf1332' } }}
                        // prefix={<ArrowDownOutlined />}
                        // suffix="%"
                        />
                    </Card>
                </Col>
            </Row>
            {/* <h3>TokenA中用户的金额：{convert(TokenA)}</h3>
            <h3>TokenB中用户的金额：{convert(TokenB)}</h3>
            <h3>TokenA中Pair的金额：{convert(PairTokenA)}</h3>
            <h3>TokenB中Pair的金额：{convert(PairTokenB)}</h3>
            <h3>Pair中用户的LP：{convert(LP)}</h3> */}
        </div >
    )
}
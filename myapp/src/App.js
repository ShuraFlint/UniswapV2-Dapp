import React from 'react'
import Content from './view/Content'
import { Provider } from 'react-redux'
import store from './redux/store'
import { BrowserRouter } from 'react-router-dom'

export default function App() {
  return (
    //使用Provider组件将store注入到组件树中，
    //然后所有的组件都可以通过state直接使用store中变量的内容
    //所有的组件都可以通过diapatch直接使用store中函数的内容
    <BrowserRouter>
      <Provider store={store}>
        <Content></Content>
      </Provider>
    </BrowserRouter>

  )
}
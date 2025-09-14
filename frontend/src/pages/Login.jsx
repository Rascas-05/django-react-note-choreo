import Form from "../components/form"

function Login() {
    //return <div>Login</div>
    return <Form route="/api/token/" method="login" />
}

export default Login
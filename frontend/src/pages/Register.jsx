import Form from "../components/form"

function Register() {
    //return <div>Register</div>
    return <Form route="/api/user/register/" method="register" />
}

export default Register
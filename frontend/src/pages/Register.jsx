import Form from "../components/Form"

function Register() {
    //return <div>Register</div>
    return <Form route="/api/user/register/" method="register" />
}

export default Register
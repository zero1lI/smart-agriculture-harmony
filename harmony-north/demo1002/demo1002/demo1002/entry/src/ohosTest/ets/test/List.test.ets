import DevTest from './Dev.test'
import abilityTest from './Ability.test';

export default function testsuite() {
  abilityTest();
  DevTest()
}